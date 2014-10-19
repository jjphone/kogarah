module SessionsHelper
	
	def signed_in_user
		unless signed_in?
			store_location request.url
			redirect_format(signin_url, {info: "Required login"}, params[:callback] )
		end
	end

	def sign_in(user)
		remember_token = User.new_remember_token
		cookies[:remember_token] = { value: remember_token, expires: 2.hours.from_now.utc }
		user.update_attribute(:remember_token, User.digest(remember_token) )
    	self.current_user = user
	end

	def sign_out 
		#update_attribute bypass password validation
		if current_user
			current_user.update_attribute(:remember_token, User.digest(User.new_remember_token) )
			cookies.delete(:remember_token)
			self.current_user = nil
		end
	end
	
	def signed_in?
		!current_user.nil?
	end

	def current_user=(user)
		@current_user = user
	end

	def current_user?(user)
		user == current_user
	end

	def current_user
		remember_token = User.digest(cookies[:remember_token])
		@current_user ||= User.find_by(remember_token: remember_token)
		@current_user
	end

	def store_location(link = nil)
		if link
			session[:return_to] = link 
		else
			session[:return_to] = request.url if request.get?
		end
		Rails.logger.debug "------  SessionsHelper#store_location :: session[:return_to] =  #{session[:return_to]}"
	end


	# returns:
	# => nil if authentiated
	# => @view with new URL if error
	def auth_user
		@user = User.find_by(id: params[:id] )
		if @user 
			if current_user? @user 
				@view = nil
			else	#show @user 
				flashs = { error: "Insufficient priviledge on @#{@user.login}" }
				user_show(@user.to_slug, flashs)
			end
		else
			flashs = { error: "Invalid user id : #{params[:id].to_i}" }
			redirect_format("/", flashs, params[:callback] )
		end
	end



end
