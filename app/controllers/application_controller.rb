class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception
	require 'rack/utils'
	#protect_from_forgery with: :null_session
	include SessionsHelper


	def redirect_format(url, message, callback)
		respond_to do |format|
			format.json {
				url = jsonp_url(url, callback)
				Rails.logger.debug "------ ApplicationController : redirect_format :: url.json = #{url}"
				redirect_to(url, format: :json, flash: message)
			}
			format.any {
				url = html_url(url)
				Rails.logger.debug "------ ApplicationController : redirect_format :: url.any = #{url}"
				redirect_to(url, format: :html, flash: message )
			}
		end
	end

	# append callback=angular.callbacks._<seq> to the url 
	def jsonp_url(url, callback)
		link = URI url
		param_hash = Rack::Utils.parse_nested_query(link.query)
		if callback 
			seq = callback[/\d+/].to_i
		else
			seq = 0
		end
		if param_hash && !param_hash.empty?
			Rails.logger.debug("---------  ApplicationController : jsonp_url :: param_hash = #{param_hash.to_s}")
			if angular_callback(link.query)
				param_hash["callback"] = "angular.callbacks._#{seq}"
				param_hash["redirect"] = true
				link.query = param_hash.to_query
			else
				link.query = {"callback"=> "angular.callbacks._#{seq}", "redirect"=> true}.merge(param_hash).to_query
			end
		else
			link.query = "callback=angular.callbacks._#{seq}&redirect=true"
		end
		Rails.logger.debug("-------- #. ApplicationController : jsonp_url( url: " +url+ " ) => #{link.to_s}")
		link.to_s
	end

	# remove callback=angular.callbacks._<seq> from url if any
	def html_url(url)
		link = URI url
		if link.query
			link.query = link.query.gsub(/callback=angular\.callbacks._\d+/ , "")
			link.query = nil unless link.query.size > 0
		end
		link.to_s
	end

	def angular_callback(query)
		Rails.logger.debug("------- ##. ApplicationController:angular_callback( query: #{query} ) ")
		callback = query[/callback=angular\.callbacks._\d+/]
		if callback
			callback[/\d+/].to_i
		else
			nil
		end
	end

	def redirect_back_or(default, message)
		link = session[:return_to] || default
		session.delete(:return_to)
		redirect_format(link, nil, params[:callback])
	end


	def parseView(flashs, page, title, url, data )
		http_path = { prev: request.env["HTTP_REFERER"], current: url }
		user = current_user ? current_user.to_h : nil
		params = { 	path: http_path, flash: flashs, 
					current_user: user, 
					template: page, title: title, data: data,  source: nil,
				}
		View.new(params)
	end


	def renderViewWithURL(syncLevel, file)
		# syncLevel = 0 - dont care
		# syncLevel = 1 - update json
		# syncLevel = 2 - js + json
		# syncLevel = 4 - all
		respond_to do |format|
			caller = [controller_name,action_name].join("#")
			format.json {
				Rails.logger.debug "--- #{caller} :: render format.json"
				@view.source = "json"
				@view.syn_url = true if syncLevel > 0 || params[:redirect]
				set_csrf_cookie_for_ng
				render json: @view, content_type: 'application/javascript' , callback: params[:callback]
			}
			format.js {
				Rails.logger.debug "--- #{caller} :: render format.js"
				@view.source = "js"
				@view.syn_url = true if syncLevel > 1
				render file if file
			}
			format.html {
				Rails.logger.debug "--- #{caller} :: render format.html"
				@view.source = "html"
				@view.syn_url = true if syncLevel > 3
				render '/layouts/default' 
			}
		end
	end


	def renderView
		renderViewWithURL(0, nil)
	end

	def set_csrf_cookie_for_ng
		cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
	end	


	def verified_request?
		Rails.logger.debug("----- verified_request " + request.headers['X_XSRF_TOKEN'].to_s)
		super || form_authenticity_token == request.headers['X_XSRF_TOKEN']
	end
	
	def asset_path(file)
		"/assets" + file
	end

end
