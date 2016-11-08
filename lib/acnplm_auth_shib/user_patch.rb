require_dependency 'user'

class User

  def self.find_or_create_from_omniauth(omniauth)
		logger = Logger.new(STDOUT)
		logger.level = Logger::INFO
		
		#First: look for an eppn match, then: look for a mail match
		user = self.find_by_eppn(omniauth['login'])
		unless user
			user = self.find_by_mail(omniauth['mail'])
		end
		#disabled: look for login match
		#user = self.find_by_login(omniauth['login'])

		#If there is no user, create it:
    unless user
      if Redmine::ACNPLMAuth.onthefly_creation?
        auth = {          
					:enterpriseid => omniauth['enterpriseid'],
					:firstname  => omniauth['firstname'],
          :lastname   => omniauth['lastname'],
          :mail       => omniauth['mail'],					
        }
        user = new(auth)
				user.login    = omniauth['login']
        user.language = Setting.default_language
        user.activate
        user.save!
        user.reload
      end
    else
			#if there is already an user: update users attributes:
			if Redmine::ACNPLMAuth.settings_hash["label_update_users_attributes"]
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
				if changed
					user.save!
				end
			end
		end
    user
  end
  
  def self.find_by_eppn(enterpriseid)
		# First look for an exact match
		user = where(:enterpriseid => enterpriseid).detect {|u| u.enterpriseid == enterpriseid}
		unless user
			# Fail over to case-insensitive if none was found
			user = where("LOWER(login) = ?", enterpriseid.downcase).first
		end
		user
  end
end
