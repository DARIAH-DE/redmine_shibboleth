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
    def label_update_user_attributes
      settings_hash["label_update_users_attributes"]
    end

    def label_delete_user_from_groups
      settings_hash["label_delete_user_from_groups"]
    end

  end

end
