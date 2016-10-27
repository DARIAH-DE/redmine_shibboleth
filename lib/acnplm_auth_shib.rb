module Redmine::ACNPLMAuth
  class << self
    def settings_hash
      Setting["plugin_acnplm_auth_shib"]
    end

    def enabled?
      settings_hash["enabled"]
    end

    def onthefly_creation?
      enabled? && settings_hash["onthefly_creation"]
    end

    def label_login_with_saml
      settings_hash["label_login_with_saml"]
    end

  end

end
