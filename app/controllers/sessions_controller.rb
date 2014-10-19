class SessionsController < ApplicationController
	def new 
		@view = createView(signin_path, session_html("new"), 'Trainbuddy | Login', flash.to_hash  )
		renderView
	end

	def create
		user = User.find_by(email: params[:session][:email].downcase)
		if user && user.authenticate(params[:session][:password])
			flashs = {info: "User login"}
			sign_in user
			redirect_back_or(current_user.to_slug, flashs)
		else
			flashs = {error: "Invalid email/password combination"}
			@view = createView("/signin?login=error", session_html("new"), 'Trainbuddy | Login - Error', flash.to_hash  )
			renderViewWithURL(4, nil)
		end
		# Rails.logger.debug @view.inspect
	end

	def destroy
		sign_out if signed_in?
		redirect_format(root_url, {info: "User logout."}, params[:callback] )
	end

private
	def session_html(page)
		case page 
		when 'new'
			asset_path("/sessions/new.html")
		when 'create'
		when 'destroy'

		end
	end

end
