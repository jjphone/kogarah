class PagesController < ApplicationController
	

	def about
		#flash = {error: "error-message", success: "success-message"}
		flashs = nil
		@view = parseView(flashs, "/assets/pages/about.html", "Trainbuddy | About", '/about', nil)
		renderView
	end

	def home
		#flashs = {error: "error-message", success: "success-message"}
		flashs = nil
		@view = parseView(flashs, "/assets/pages/home.html", "Trainbuddy | Home", '/', nil)
		renderView
	end

	def help
		#flashs = {error: "error-message", success: "success-message", info: "info-message"}
		flashs = nil
		@view = parseView(flashs, "/assets/pages/help.html", "Trainbuddy | help",'/about?sourece=PagesController&action=help', nil)
		renderView
	end

	def contact
		#flashs = {error: "error-message", success: "success-message"}
		flashs = nil
		@view = parseView(flashs, "/assets/pages/contact.html", "Trainbuddy | Contact", '/contact#page', nil)
		renderView
	end

end
