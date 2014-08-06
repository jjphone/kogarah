class PagesController < ApplicationController
	

	def about
		flash = {error: "error-message", success: "success-message"}
		@view = parseView(flash, "/assets/pages/about.html", "Trainbuddy | About", nil)
		renderView
	end

	def home
		flash = {error: "error-message", success: "success-message"}
		@view = parseView(flash, "/assets/pages/home.html", "Trainbuddy | Home", nil)
		renderView
	end

	def help
		flash = {error: "error-message", success: "success-message", info: "info-message"}
		@view = parseView(flash, "/assets/pages/help.html", "Trainbuddy | help",nil)
		renderView
	end

	def contact
		flash = {error: "error-message", success: "success-message"}
		@view = parseView(flash, "/assets/pages/contact.html", "Trainbuddy | Contact", nil)
		renderView
	end

end
