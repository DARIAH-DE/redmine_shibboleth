require_dependency 'account_controller'
require 'logger'

module Redmine::ACNPLMAuth
  module AccountControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        alias_method_chain :login, :saml
        alias_method_chain :logout, :saml
      end
    end

    module InstanceMethods

      def login_with_saml
        if saml_settings["enabled"] && saml_settings["replace_redmine_login"]
          redirect_to :controller => "account", :action => "login_with_saml_redirect", :provider => "saml", :origin => back_url
        else
          login_without_saml
        end
      end

      def login_with_saml_redirect		        	
				#EPPN formatting because of the "at"
				eppn = request.headers['HTTP_EPPN']
				if eppn.include? '@'
					eppn1 = eppn.split('@')[0]
					eppn2 = eppn.split('@')[1]
					eppn = eppn1 + eppn2
				end

				auth = {
					"firstname" => request.headers['HTTP_GIVENNAME'],
					"lastname"	=> request.headers['HTTP_SN'],
					"mail" => request.headers['HTTP_MAIL'],
					"displayname" => request.headers['HTTP_CN'],
					"login" => eppn,
					"uid" => eppn,
					"enterpriseid" => eppn,
					"provider" => "shibboleth"
				}	

				logger = Logger.new(STDOUT)
				logger.level = Logger::INFO

				user = User.find_or_create_from_omniauth(auth)

        if user.blank?          
					logger.warn "Failed login for '#{auth['uid']}' from #{request.remote_ip} at #{Time.now.utc}"
          error = l(:notice_account_invalid_creditentials).sub(/\.$/, '')
          if saml_settings["enabled"]                        
						error << ". Could not find account for #{auth['uid']}"
          end
          if saml_settings["replace_redmine_login"]
            render_error({:message => error.html_safe, :status => 403})
            return false
          else
            flash[:error] = error
            redirect_to signin_url
          end
        else
					params[:back_url] = request.protocol+request.headers["HTTP_HOST"]+request.headers["SCRIPT_NAME"]
          successful_authentication(user)
          #cannot be set earlier, because sucessful_authentication() triggers reset_session()
          session[:logged_in_with_saml] = true
					#Group<->Users Sync
					if saml_settings["label_sync_groups"]
						ismemberof = request.headers['HTTP_ISMEMBEROF']
						ismemberof = ismemberof.split(';')
						ismemberof.each do |i|
							group = Group.find_by_lastname(i)
							unless group.present?
								if saml_settings["label_create_groups"]
									group = Group.new(:lastname => i.force_encoding('UTF-8'))
									group.save
									logger.info "created Group:"
									logger.info group.lastname
								end
							end
							if group.present?
								users = group.users
								unless users.include?(user)
									group.users << user
									logger.info "added User:"
									logger.info user.login
									logger.info "to Group:"
									logger.info group.lastname
								end
							end
						end
						#if user gets deleted in groups on LDAP side, he will be deleted in groups on redmine side as well:
						if saml_settings["label_delete_user_from_groups"]
							ismemberof = request.headers['HTTP_ISMEMBEROF']
							ismemberof = ismemberof.split(';')
							#Forcing to UTF-8, because umlauts made problems
							ismemberof.map! {|item| item.force_encoding('UTF-8')}
							groups = user.groups
							groups.each do |i|
								if !ismemberof.include? i.lastname
									logger.info "deleted user"
									logger.info i.lastname
									logger.info "from group:"
									group = Group.find_by_lastname(i)
									logger.info group
									groups.delete(group)
								end
							end				
						end
					end
				end
			end

      def login_with_saml_callback		
				eppn = request.headers['HTTP_EPPN']	
				#EPPN formatting because of the "at"
				if eppn.include? '@'
					eppn1 = eppn.split('@')[0]
					eppn2 = eppn.split('@')[1]
					eppn = eppn1 + eppn2
				end

				auth = {
					"firstname" => request.headers['HTTP_GIVENNAME'],
					"lastname"	=> request.headers['HTTP_SN'],
					"mail" => request.headers['HTTP_MAIL'],
					"displayname" => request.headers['HTTP_CN'],
					"login" => eppn,
					"uid" => eppn,
					"enterpriseid" => eppn,
					"provider" => "shibboleth"
				}	

				logger = Logger.new(STDOUT)
				logger.level = Logger::INFO	
        
        user = User.find_or_create_from_omniauth(auth) 

        if user.blank?          
					logger.warn "Failed login for '#{auth['uid']}' from #{request.remote_ip} at #{Time.now.utc}"
          error = l(:notice_account_invalid_creditentials).sub(/\.$/, '')
          if saml_settings["enabled"]            
						error << ". Could not find account for #{auth['displayname']}"
          end
          if saml_settings["replace_redmine_login"]
            render_error({:message => error.html_safe, :status => 403})
            return false
          else
            flash[:error] = error
            redirect_to signin_url
          end
        else
          user.update_attribute(:last_login_on, Time.now)
					params[:back_url] = request.headers.protocol+request.headers["HTTP_HOST"]+request.headers["SCRIPT_NAME"]
          successful_authentication(user)
          session[:logged_in_with_saml] = true
					
          #Group<->Users Sync
					if saml_settings["label_sync_groups"]
						ismemberof = request.headers['HTTP_ISMEMBEROF']
						ismemberof = ismemberof.split(';')
						ismemberof.each do |i|
							group = Group.find_by_lastname(i)
							unless group.present?
								if saml_settings["label_create_groups"]
									group = Group.new(:lastname => i.force_encoding('UTF-8'))
									group.save
									logger.info "created Group:"
									logger.info group.lastname
								end
							end
							if group.present?
								users = group.users
								unless users.include?(user)
									group.users << user
									logger.info "added User:"
									logger.info user.login
									logger.info "to Group:"
									logger.info group.lastname
								end
							end
						end
						#if user gets deleted in groups on LDAP side, he will be deleted in groups on redmine side as well:
						if saml_settings["label_delete_user_from_groups"]
							ismemberof = request.headers['HTTP_ISMEMBEROF']
							ismemberof = ismemberof.split(';')
							#Forcing to UTF-8, because umlauts made problems
							ismemberof.map! {|item| item.force_encoding('UTF-8')}
							groups = user.groups
							groups.each do |i|
								if !ismemberof.include? i.lastname
									logger.info "deleted user"
									logger.info i.lastname
									logger.info "from group:"
									group = Group.find_by_lastname(i)
									logger.info group
									groups.delete(group)
								end
							end				
						end
					end
				end
      end

      def login_with_saml_failure		
        error = params[:message] || 'unknown'
        error = 'error_saml_' + error
        if saml_settings["replace_redmine_login"]
          render_error({:message => error.to_sym, :status => 500})
          return false
        else
          flash[:error] = l(error.to_sym)
          redirect_to signin_url
        end
      end

      def logout_with_saml		
        if saml_settings["enabled"] && session[:logged_in_with_saml]
          logout_user
          redirect_to saml_logout_url(home_url)
        else
          logout_without_saml
        end
      end

      private
      def saml_settings		
        Redmine::ACNPLMAuth.settings_hash
      end

      def saml_logout_url(service = nil)		
				logout_url_settings = Setting["plugin_acnplm_auth_shib"]["label_logout_url"]
        unless logout_url_settings.blank?
          logout_uri = logout_url_settings
        end
        logout_uri unless logout_uri.blank?
				logout_uri || home_url
      end

    end
  end
end

unless AccountController.included_modules.include? Redmine::ACNPLMAuth::AccountControllerPatch	
  AccountController.send(:include, Redmine::ACNPLMAuth::AccountControllerPatch)
  AccountController.skip_before_filter :verify_authenticity_token, :only => [:login_with_saml_callback]
end