class SessionsController < ApplicationController
	def new 
		Rails.logger.debug "----- Sessions#new"
		flashs = flash.to_hash
		flash.clear
		@view = parseView(flashs, html_page('new'), 'Trainbuddy | Login', signin_path, nil)
		renderView
	end

	def create
		Rails.logger.debug "----- Sessions#create"
		user = User.find_by(email: params[:session][:email].downcase)
		if user && user.authenticate(params[:session][:password])
			sign_in user
			redirect_back_or(current_user.to_slug, {info: "User login."} )
		else
			flashs = {error: "Invalid email/password combination"}
			@view = parseView( flashs, html_page("new"), "Trainbuddy | Login - Error", "/signin?login=error", nil)
			renderViewWithURL(4, nil)
		end
		# Rails.logger.debug @view.inspect
	end

	def destroy
		Rails.logger.debug "----- Sessions#destroy"
		sign_out
		redirect_format(root_url, {info: "User logout."}, params[:callback] )
	end
	
	def html_page(page)
		case page 
		when 'new'
			asset_path("/sessions/new.html")
		when 'create'
		when 'destroy'

		end
	end

end
