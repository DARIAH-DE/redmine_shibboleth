require_dependency 'user'

class User

  def self.find_or_create_from_omniauth(omniauth)
		logger = Logger.new(STDOUT)
		logger.level = Logger::INFO
		user = self.find_by_login(omniauth['login'])
		unless user
			user = self.find_by_mail(omniauth['mail'])
		end

    unless user
      if Redmine::ACNPLMAuth.onthefly_creation?
        auth = {          
					:enterpriseid => omniauth['enterpriseid'],
					:firstname  => omniauth['firstname'],
          :lastname   => omniauth['lastname'],
          :mail       => omniauth['mail'],
					:displayname	=> omniauth['displayname']					
        }
        user = new(auth)
				user.login    = omniauth['login']
        user.language = Setting.default_language
        user.activate
        user.save!
        user.reload
      end
    else
			if saml_settings["label_update_users_attributes"]
				changed = false
				if !omniauth['login'].nil? && (omniauth['login'] != user.login)
					user.login = omniauth['login']
					changed = true
				end
				if !omniauth['mail'].nil? && (omniauth['mail'] != user.mail)
					user.mail = omniauth['mail']
					changed = true
				end
				if !omniauth['firstname'].nil? && (omniauth['firstname'] != user.firstname)
					user.firstname = omniauth['firstname']
					changed = true
				end
				if !omniauth['lastname'].nil? && (omniauth['lastname'] != user.lastname)
					user.lastname = omniauth['lastname']
					changed = true
				end
				if !omniauth['enterpriseid'].nil? && (omniauth['enterpriseid'] != user.enterpriseid)
					user.enterpriseid = omniauth['enterpriseid']
					changed = true
				end
				if !omniauth['displayname'].nil? && (omniauth['displayname'] != user.displayname)
					user.displayname = omniauth['displayname']
					changed = true
				end
				if changed
					user.save!
				end
			end
		end
    user
  end
  
	def self.find_by_eppn(enterpriseid)
	  # force string comparison to be case sensitive on MySQL
	  if user 
	    logger.info "user exists"
	    user = User.where(:enterpriseid => enterpriseid)
	  end
	end  

end
