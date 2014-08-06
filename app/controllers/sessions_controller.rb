class SessionsController < ApplicationController
	def new 
		Rails.logger.debug "----- Sessions#new"
		flashs = flash.to_hash

		Rails.logger.debug ("----- flash"+flash.inspect)
		flash.clear
		@view = parseView(flashs, session_page('new'), 'Trainbuddy | Login', nil, nil)
		renderView
	end

	def create
		Rails.logger.debug "----- Sessions#create"
		user = User.find_by(email: params[:session][:email].downcase)
		if user && user.authenticate(params[:session][:password])

			sign_in user
			#flashs = {success: "user login"}
			#@view = parseView( flashs, session_page("home"), "Trainbuddy | #{user.name}", "/home", nil)
			if session[:return_to]
				redirect_to session[:return_to]
			else
				@view = initView
				@view.parse_user(current_user, nil, template_path("/users/show.html"), nil )

			end

			redirect_back_or current_user
			@view = parseView( nil,  )
		else
			flashs = {error: "Invalid email/password combination"}
			@view = parseView( flashs, session_page("new"), "Trainbuddy | Login", "/signin", nil)
			renderView
		end
		Rails.logger.debug @view.inspect
		
	end

	def destroy
		Rails.logger.debug "----- Sessions#destroy"
		sign_out
		redirect_to root_url

	end
	
	def session_page(page)
		case page 
		when 'new'
			template_path "/sessions/new.html"
		when 'create'
		when 'destroy'
		when "home"
			template_path "/pages/home.html"
		end
	end

end
