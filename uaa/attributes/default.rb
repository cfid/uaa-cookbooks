default['deployment']['user'] = nil
default['deployment']['home'] = '/tmp'
default['uaadb']['host'] = 'localhost'
default['uaadb']['port'] = 5432
default['uaadb']['database'] = 'postgres'
default['uaadb']['username'] = 'postgres'
default['uaadb']['password'] = "#{node['postgresql']['password']['postgres']}"
default['uaa']['admin']['password'] = 'adminsecret'
default['uaa']['clients'] = {}
