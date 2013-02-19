# UAA Cookbooks for Chef

This project is a set of
[chef recipes](http://wiki.opscode.com/display/chef/Recipes) for
installing and running the latest UAA from
[github](http://github.com/cloudfoundry/uaa).  E.g. with `chef-solo`
you could use a `solo.json` like this and something would work and
leave a UAA running at the root context on port 8080:

    {
      "postgresql":{
        "password":{ "postgres": "postgres" } // Mandatory for chef-solo
      },
      "run_list":["recipe[git]", "recipe[postgresql::server]", "recipe[tomcat]", "recipe[maven::maven3]", "recipe[uaa]"]
    }
    
A quick test (you might need to install curl if the target system started empty):

    $ curl -v -H "Accept: application/json" localhost:8080/login

## More Configuration Options

By default the system will come up with a postgresql database but only
one registered (admin) client and no users. You could add some
bootstrap data to `solo.json` as well:

    {
      "run_list": ["recipe[git]", "recipe[postgresql::server]", "recipe[tomcat]", "recipe[maven::maven3]", "recipe[uaa]"],
      "postgresql":{
        "password":{ "postgres": "postgres" }
      },
      "deployment": {
        "user" : "vagrant",
        "home" : "/home/vagrant"
      },
      "uaa": {
        "users": [ "marissa|koala|marissa@test.org|Marissa|Bloggs|uaa.user" ],
        "clients": {
          "cloud_controller": {
            "authorized-grant-types": "client_credentials",
            "scope": "uaa.none",
            "authorities": "scim.read,scim.write,password.write,uaa.resource",
            "id": "cloud_controller",
            "secret": "cloudcontrollerclientsecret",
            "resource-ids": "none",
            "access-token-validity": 604800
          },
          "vmc": {
            "authorized-grant-types": "implicit",
            "scope": "cloud_controller.read,cloud_controller.write,password.write,openid",
            "authorities": "uaa.none",
            "id": "vmc",
            "resource-ids": "none",
            "redirect-uri": "http://uaa.cloudfoundry.com/redirect/vmc,https://uaa.cloudfoundry.com/redirect/vmc",
            "access-token-validity": 604800,
            "autoapprove": true
          }
        }
      }
    }
