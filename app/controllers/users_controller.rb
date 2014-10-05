class UsersController < ApplicationController

	include UsersHelper
	
	before_action :signed_in_user, 	except: [:new, :create]
	before_action :auth_user, 		only: [:edit, :update, :destroy]

	def index
		Rails.logger.debug "------ User#index"
		users = User.paginate(page: params[:page])
		list_users("/users", user_html("index"), users, "/users", nil )
		renderView
	end

	def show
		Rails.logger.debug "------ Users#show"
		@user = User.find_by_id(params[:id] )
		if @user 
			show_user(current_user.id, request.fullpath, user_html("show"), flash.to_hash )
			renderView
		else	#render users - list
			flashs = { error: "Invalid user id : #{params[:id].to_i}" }
			users = User.paginate(page: params[:page])
			list_users("/users", user_html("index"), users, "/users", flashs )
			renderViewWithURL(4, nil)
		end
	end

	def edit
		Rails.logger.debug "------ Users#Edit"
		#before action auth_user
		if @view # insufficient priviledge
			renderViewWithURL(4, nil)
		else  
			@view = createView(request.fullpath, user_html("edit"), nil, flash.to_hash )
			@view.user_main(@user)
			renderView
		end
	end


	def update
		Rails.logger.debug "------ User#Update - find_by_id" 
		#auth_user
		if @view #insufficient priviledge
			renderViewWithURL(4,nil)
		else
			if @user.update(user_params("edit"))
				flashs = {success: "User profile updated"}
				@user.reload
				show_user(@user.id, "/users/#{@user.id}", user_html("show"), flashs)
			else
				flashs = {error: "Can't update profile"}
				@view = createView("#{@user.to_slug}/edit", user_html("edit"), nil, flashs )
				@view.user_main(@user)
			end
			renderViewWithURL(4,"update.js.erb")
		end
	end


	def new 
		Rails.logger.debug "------ User#New"
		@view = createView("/users/new", user_html("new"), "Trainbuddy | new",  flash.to_hash )
		@view.main = {type: "user", pack: User.new.to_h}
		renderView
	end

	def create
		Rails.logger.debug "------   User#Create"
		@user = User.new(user_params("create"))	
		if @user.save
			flashs = {success: "User created"}
			@user.reload
			sign_in @user
			show_user(@user.id, @user.to_slug, user_html("show"), flashs )
		else
			flashs = {error: "User can't be created"}
			@view = createView("/users/new", user_html("new"), "Trainbuddy | new",  flashs)
			@view.user_main(@user)
		end
		renderViewWithURL(4,"update.js.erb" )
	end

	def destroy
	end


private

	def user_params(action)
		if action == "create"
			params.require(:user).permit!
		else 
			params.require(:user).permit(:name, :phone, :email, :avatar, :password, :password_confirmation)
		end
	end


end
