class RelationshipsController < ApplicationController
	include UsersHelper
	before_action :signed_in_user


	def index
	end


	def update
		Rails.logger.debug "------ relationships#update"
		other_params = nil

		@user = User.find_by_id( params[:user] )
		if @user 
			res = current_user.set_relation_with( @user.id, params[:op], params[:nick] )
			if res == -2
				flash[:error] = "Error occured while trying #{relation_name(params[:op]) }"
			else
				flash[:info] = "Relation has been updated with #{ relation_name(res) }"
			end
		end
		
		respond_to do |format|
			format.json {
				show_user( current_user.id, other_params )
			}
			format.html {
				redirect_to @user
			}
		end
	end

private
	def relation_name(code)
		case code.to_i
		when -1
			"block user"
		when 0 
			"unfriend user"
		when 1
			"request friend"
		when 2
			"pending confirmation"
		when 3
			"accept friend"
		when 5
			"update alias"
		else
			"unknow"
		end
	end


end
