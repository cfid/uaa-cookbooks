#
# Cookbook Name:: uaa
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

uaa_home = File.join(node['deployment']['home'], "uaa")
uaa_checkout = File.join(uaa_home, "checkout")
uaa_config = File.join(node['deployment']['home'], "config")
uaa_yml = File.join(uaa_config, "uaa.yml")

directory "Config Directory" do
  owner node['deployment']['user']
  recursive true
  path "#{uaa_config}"
end

git "Checkout UAA Code" do
  user node['deployment']['user']
  repository "git://github.com/cloudfoundry/uaa.git"
  reference "master"
  action :checkout
  destination uaa_checkout
end

template "uaa.yml" do
  path "#{uaa_yml}"
  source "uaa.yml.erb"
  owner node['deployment']['user']
  mode 0644
end

bash "Build UAA" do
  user node['deployment']['user']
  code <<-EOH
    cd #{uaa_checkout}; mvn clean install -U -DskipTests=true
  EOH
  not_if "[ -e #{uaa_checkout}/uaa/target/cloudfoundry-identity-uaa-*.war ]"
end

unless `grep uaa.yml /etc/default/tomcat6`

  bash "Add UAA config to Tomcat" do
    code <<-EOH
      sed -i -e 's,\(.*\)JAVA_OPTS="\([^$].*\)"$,\1JAVA_OPTS="\2 -DUAA_CONFIG_URL=file:#{uaa_yml}",' /etc/default/tomcat6
    EOH
  end

  service "tomcat6" do
    action :restart
  end

end

bash "Deploy UAA" do
  code <<-EOH
    cp #{uaa_checkout}/uaa/target/cloudfoundry-identity-uaa-*.war #{node['tomcat']['webapp_dir']}/ROOT.war
  EOH
end
