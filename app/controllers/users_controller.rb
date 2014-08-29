class UsersController < ApplicationController

	include UsersHelper
	
	before_action :signed_in_user, 	except: [:new, :create]
	before_action :auth_user, 		only: [:edit, :update, :destroy]

	def index
		Rails.logger.debug "---- #index"
		users = User.paginate(page: params[:page])
		
		@view = parseView(nil, user_page("index"), "Trainbuddy | Users", "/users", nil)
		@view.parse_paginate("users", users, "/users", users.map(&:to_h) )
		gen_links( {all:"/users", friends:"/users?type=3", pending:"/users?type=2", blocked:"/users?type=-1", requested:"/users?type=1"} )

		renderView
	end

	def show
		Rails.logger.debug "----- users#show"
		@user = User.find_by_id(params[:id] )
		show_user( current_user.id, nil )
	end

	def edit
		Rails.logger.debug "---- #edit"
		@user = User.find_by_id(params[:id])
		@view.parse_user(@user,"/edit", user_page("edit"), user_page("index"))
		renderView
	end

	def update
		Rails.logger.debug "---- #update"
		#@user = fetch_user
		@user = User.find_by_id(params[:id])
		@view = initView
		if @user
			if @user.update(user_params("edit") )
				@user.reload
				@view.parse_user(@user, nil, user_page("show"), nil)
				@view.flash = {success: "User profile updated"}
			else
				@view.parse_user(@user, "/edit", user_page("edit"), nil)
				@view.flash = { error: "User: Error while updating profile"}
			end
		else
			@view.parse_user(nil, nil, nil, user_page("index"))
		end
		renderView('update.js.erb')
	end

	def new 
		Rails.logger.debug "----   #new"
		@view = parseView(nil, user_page("new"), "Trainbuddy | new", "/users/new", nil)
		@view.main = {type: "user", pack: User.new.to_h}
		renderView
	end

	def create
		Rails.logger.debug "----   #create"
		@user = User.new(user_params("create"))
		@view = initView
		if @user.save
			@user.reload
			sign_in user
			@view.parse_user(@user, nil, user_page("show"), nil)
			@view.flash = {success: "User created"}
			gen_links( associate_actions(current_user.id @user.id) )
		else
			@view.parse_user(@user, "new", user_page("new"), nil)
			@view.flash = {error: "user can't be created"}
			@view.title = "Trainbuddy | New User"
		end
		renderView('update.js.erb')
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
