class PagesController < ApplicationController
	

	def about
		#flash = {error: "error-message", success: "success-message"}
		msg = nil
		@view = createView("/about", asset_path("/pages/about.html"), "Trainbuddy | About", flash.to_hash )
		renderView
	end

	def home
		#msg = {error: "error-message", success: "success-message"}
		msg = nil
		@view = createView("/", asset_path("/pages/home.html"), "Trainbuddy | Home", flash.to_hash )
		renderView
	end

	def help
		#msg = {error: "error-message", success: "success-message", info: "info-message"}
		msg = nil
		@view = createView("/help", asset_path("/pages/help.html"), "Trainbuddy | Help", flash.to_hash )
		@view.data = request.fullpath

		renderView
	end

	def contact
		#msg = {error: "error-message", success: "success-message"}
		msg = nil
		@view = createView("/contact", asset_path("/pages/contact.html"), "Trainbuddy | Contact", flash.to_hash )
		renderView
	end

end
