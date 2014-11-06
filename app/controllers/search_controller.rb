class SearchController < ApplicationController
	before_action :signed_in_user

	def index
		@view = createView("/search", search_html, site_title('Search'), nil)
		if params[:type] == "tag" && params[:term].size > 0
			# user_tag
			term = params[:term].gsub(/\W/, '')
			res = current_user.search_user_tag(term, params[:avoid] )
			Rails.logger.debug "Search#index : params[:avoid] = #{params[:avoid]}"
			@view.flash = {info: "No user found"} unless res.size > 0
			@view.main = { type: "search", pack: {type: "tag", term: term, result: res } }
		end
		renderView
	end


private
	def search_html
		asset_path("/search/index.html")
	end

end
