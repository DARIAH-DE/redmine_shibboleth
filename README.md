# Shibboleth Authentication Plugin for Redmine
This Plugin adds customized Shibboleth Authentication for [Redmine](http://www.redmine.org) 3.3.0 stable.

## Database
Add one more column into table users:
```
ALTER TABLE `users` ADD `enterpriseid` VARCHAR(127) CHARACTER SET utf8 COLLATE utf8_general_ci NULL;
```

## Shibboleth

Add these lines into your HTTP Server file. For example for Apache2 with a shibd2 deamon: /etc/apache2/sites-enabled/000-default.conf
```
        <Location /Shibboleth.sso>
          SetHandler shib
        </Location>

        <Location /auth/saml>
          AuthType shibboleth
          ShibRequestSetting requireSession 1
          require valid-user
          ShibUseHeaders On

          RequestHeader set eppn %{eppn}e
          RequestHeader set mail %{mail}e
          RequestHeader set cn %{cn}e
          RequestHeader set sn %{sn}e
          RequestHeader set givenName %{givenName}e
          RequestHeader set isMemberOf %{isMemberOf}e
        </Location>
```

Restart apache2

```sudo service apache2 restart```

# Install

You can first take a look at general instructions for plugins [here](http://www.redmine.org/wiki/redmine/Plugins).

Note that the plugin was only tested with *Redmine 3.3.0 stable*, *Ruby 2.3.1* and *Rails 4.2.7.1*.

1. clone this repository in your plugins/ directory

2. change the name of this plugin folder ("redmine_shibboleth") to "acnplm_auth_shib"

3. install the dependencies with bundler: 
    ```bundle install```

4. copy assets by running this command from your redmine root directory (note: the plugin has no migration for now):
```rake redmine:plugins:migrate RAILS_ENV=production```
After that you can adapt your Shibboleth internal settings especially for attribute mappings in
  - plugins/acnplm_auth_shib/lib/acnplm_auth_shib/user_patch.rb
  - plugins/acnplm_auth_shib/lib/acnplm_auth_shib/account_controller_patch.rb

5. restart your Redmine instance (depends on how you host it)

Finally you need to configure some minor options for the plugin to work, in "Administration" > "Plugins" > "Configure" on the Shib Authentication plugin line.


## Development

This tool has been developed within the “Humanities at Scale” project.
This project has received funding from the European Union’s Horizon 2020 research and innovation programme under grant agreement 675570.
