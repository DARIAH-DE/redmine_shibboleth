require_dependency 'user'

class User

    def self.find_or_create_from_omniauth(omniauth)
    user = self.find_by_login(omniauth['login'])
	
    unless user
      if Redmine::ACNPLMAuth.onthefly_creation?
        auth = {          
		  :enterpriseid => omniauth['enterpriseid'],
		  :firstname  => omniauth['firstname'],
          :lastname   => omniauth['lastname'],
          :mail       => omniauth['mail']		  
        }
        user = new(auth)
	user.login    = omniauth['login']		
        user.language = Setting.default_language
        user.activate
        user.save!
        user.reload
      end
    end
    user
  end
  
	def self.find_by_eppn(enterpriseid)
	  # force string comparison to be case sensitive on MySQL
	  if user 
	    logger.warn "user exists"
	    user = User.where(:enterpriseid => enterpriseid)
	  end
	end  

end
