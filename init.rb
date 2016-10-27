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
  name 'ACN PLM Authentication plugin'
  description "This plugin adds customized Shibboleth authentication support to Redmine. Based on Redmine Omniauth SAML plugin of Christian A. Rodriguez."
  author 'Chau Khoa'
  author_url 'https://github.com/chaukhoa'
  url 'https://github.com/chaukhoa/acnplm_auth_shib'
  version '0.0.1'
  requires_redmine :version_or_higher => '2.4.4'
  settings :default => { 'enabled' => 'false', 'label_login_with_saml' => 'Shibboleth Authentication', 'replace_redmine_login' => false  },
           :partial => 'settings/acnplm_auth_shib_settings'
end

