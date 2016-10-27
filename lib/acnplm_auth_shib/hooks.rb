module Redmine::ACNPLMAuth
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_account_login_top, :partial => 'acnplm_auth_shib/view_account_login_top'
  end
end
