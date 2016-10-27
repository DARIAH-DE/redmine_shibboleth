RedmineApp::Application.routes.draw do
  match 'auth/failure', :to => 'account#login_with_saml_failure', :via => [:get, :post]
  match 'auth/:provider/callback', :to => 'account#login_with_saml_callback', :via => [:get, :post]
  match 'auth/:provider', :to => 'account#login_with_saml_redirect', :via => [:get, :post]
end
