require 'redmine'
require 'acnplm_auth_shib'
require 'acnplm_auth_shib/hooks'
require 'acnplm_auth_shib/user_patch'

# Patches to existing classes/modules
ActionDispatch::Callbacks.to_prepare do
  require_dependency 'acnplm_auth_shib/account_helper_patch'
  require_dependency 'acnplm_auth_shib/account_controller_patch'
end

# Plugin generic informations
Redmine::Plugin.register :acnplm_auth_shib do
  name 'Shibboleth Authentication plugin'
  description "This plugin adds customized Shibboleth authentication support to Redmine. Based on Redmine Omniauth SAML"
  author 'Markus Matoni'
  url 'https://github.com/DARIAH-DE/redmine_shibboleth'
  version '0.1'
  requires_redmine :version_or_higher => '3.2'
  settings :default => { 'enabled' => 'false', 'label_login_with_saml' => 'Shibboleth Authentication', 'replace_redmine_login' => false, 'label_logout_url' => 'https://dev5.de.dariah.eu/Shibboleth.sso/Logout', 'label_sync_groups' => false, 'label_create_groups' => false  },
           :partial => 'settings/acnplm_auth_shib_settings'
end

