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
				url = add_params(url, {redirect: true} )
				Rails.logger.debug "----- redirect_format : url = #{url}"
				redirect_to(url, format: :json, flash: message)
			}
			format.any {
				url = remove_param(url, "callback")
				redirect_to(url, format: :html, flash: message )
			}
		end
	end

	# append callback=angular.callbacks._<seq> to the url 
	def jsonp_url(url, callback)
		seq = callback ? callback[/\d+/].to_i : 0
		add_params(url, {callback: "angular.callbacks._#{seq}", redirect: true} )
	end

	def add_params(url, set)
		link = URI url
		if link.query
			params = Rack::Utils.parse_nested_query(link.query)
			set.each_key{ |k| params.delete(k) }
			link.query = set.merge(params).to_query
		else
			link.query = set.to_query
		end
		link.to_s
	end

	def remove_param(url, name)
		link = URI url
		if link.query 
			params = Rack::Utils.parse_nested_query(link.query)
			params.delete(name)
			link.query = (params.size > 0 ) ? params.to_query : nil
		end
		link.to_s
	end

	def angular_callback(query)
		callback = query[/callback=angular\.callbacks._\d+/]
		return callback ? callback[/\d+/].to_i : nil
	end

	def redirect_back_or(default, message)
		link = session[:return_to] || default
		session.delete(:return_to)
		redirect_format(link, nil, params[:callback])
	end


	def createView(url, page, title, flash)
		paths = { prev: remove_param(request.env["HTTP_REFERER"].to_s, "callback"), current: remove_param(url, "callback") }
		user = current_user ? current_user.to_h(nil, 4) : nil
		View.new( {path: paths, flash: flash, current_user: user, template: page, title: title} )
	end


	def renderViewWithURL(syncLevel, file)
		# syncLevel = 0 - dont care
		# syncLevel = 1 - update json
		# syncLevel = 2 - js + json
		# syncLevel = 4 - all
		flash.clear
		respond_to do |format|
			caller = [controller_name,action_name].join("#")
			format.json {
				@view.source = "json"
				if syncLevel > 0 || params[:redirect]
					@view.syn_url = true
					@view.path[:current] = remove_param( @view.path[:current], "redirect" )
				end
				set_csrf_cookie_for_ng
				render json: @view, content_type: 'application/javascript' , callback: params[:callback]
			}
			format.js {
				@view.source = "js"
				@view.syn_url = true if syncLevel > 1
				render file if file
			}
			format.html {
				@view.source = "html"
				@view.syn_url = true if syncLevel > 3
				render '/layouts/default' 
			}
		end
	end

	# return array of menu links
	def get_links(group, key, main_id)
		items = Menu.where(group: group, key: key).includes(:link)
		links = items.map{ |m|
			url = m.link.url 
			if m.link.substitue
				url.gsub!('##current_user_id##',current_user.id.to_s) if m.link.substitue > 1 # 2, 3
				url.gsub!('##main_id##',main_id.to_s) if m.link.substitue%2 == 1 # 1,3
			end
			{name: m.link.display, url: url, method: m.link.method}
		}
	end


	def renderView
		renderViewWithURL(0, nil)
	end

	def set_csrf_cookie_for_ng
		cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
	end	


	def verified_request?
		# Rails.logger.debug("----- verified_request " + request.headers['X_XSRF_TOKEN'].to_s)
		super || form_authenticity_token == request.headers['X_XSRF_TOKEN']
	end
	
	def asset_path(file)
		"/assets" + file
	end

	def site_title(append)
		"Trainbuddy | #{append}"
	end

end
