class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception
	#protect_from_forgery with: :null_session
	include SessionsHelper


	def parseView(flashs, page, title, url, data=nil)
		http_path = { prev: request.env["HTTP_REFERER"], current: url }
		user = current_user ? current_user.to_h : nil
		params = { 	path: http_path, flash: flashs, 
					current_user: user, 
					template: page, title: title, data: data,  source: nil }
		View.new(params)
	end


	def initView
		parseView(nil, nil, nil, nil, nil)
	end



	def renderView(file=nil)
		respond_to do |format|
			caller = [controller_name,action_name].join("#")
			format.json {
				Rails.logger.debug "--- #{caller} :: render format.json"
				@view.source = "json"
				set_csrf_cookie_for_ng
				render json: @view, content_type: 'application/javascript' , callback: params[:callback]
			}
			format.html {
				Rails.logger.debug "--- #{caller} :: render format.html"
				Rails.logger.debug "---- @view.html ::  "
				Rails.logger.debug  @view.inspect
				@view.source = "html"
				render '/layouts/default' 
			}
			format.js {
				@view.source = "js"
				render file if file
			}
		end
	end

	def set_csrf_cookie_for_ng
		cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
	end	


	def verified_request?
		Rails.logger.debug("----- verified_request " + request.headers['X_XSRF_TOKEN'].to_s)
		super || form_authenticity_token == request.headers['X_XSRF_TOKEN']
	end

	def template_path(file)
		"/assets"+file
	end

	def user_page( urlSuffix)
		@view = initView
		@view.parse_user(@user, urlSuffix, template_path("/users/edit.html"), nil )

	end
	
end
