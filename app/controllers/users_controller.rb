class UsersController < ApplicationController
	before_action :signed_in_user, 	except: [:new, :create]
	before_action :auth_user, 		only: [:edit, :update, :destroy]

	def index
		Rails.logger.debug "---- #index"
		users = User.paginate( page: params[:page])
		
		@view = parseView(nil, user_page("index"), "Trainbuddy | Users", "/users", nil)
		@view.parse_paginate("users", users, "/users", users.map(&:to_h) )
		gen_links( {all:"/users", friends:"/users?type=3", pending:"/users?type=2", blocked:"/users?type=-1", requested:"/users?type=1"} )

		renderView
	end

	def show
		Rails.logger.debug "---- #show"
		@user = fetch_user
		@view = initView
		if @view.parse_user(@user, nil, user_page("show"), user_page("index"))
			gen_links(action_with(@user))
			#posts = @user.posts.includes(:user).paginate(page)
			posts = @user.posts.paginate(page: params[:page])
			paginate = posts.map {|p| p.to_h(@user.name, @user.avatar.url) }
			@view.parse_paginate("posts", posts, "/users/#{@user.id}", paginate )
		end	
		@view.flash = flash.to_hash
		flash.clear
		renderView
	end

	def edit
		Rails.logger.debug "---- #edit"
		@user = fetch_user
		@view = initView
		@view.parse_user(@user,"/edit", user_page("edit"), user_page("index"))
		renderView
	end

	def update
		Rails.logger.debug "---- #update"
		@view = initView
		@user = fetch_user
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
			gen_links( action_with(@user) )
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



	def fetch_user
		user_id = params[:id].to_i
		user = User.find_by({id: user_id})
		Rails.logger.debug("---- fetch_user:: " + user.inspect() )
		return user
	end

	def user_page(page)
		case page 
		when 'new'
			template_path "/users/new.html"
		when 'show'
			template_path "/users/show.html"
		when 'edit'
			template_path "/users/edit.html"
		else
			template_path "/users/index.html"
		end
	end


	def gen_links(levels)
		@view.related_links( {home: "/", messages: "/chats", map: "/maps"} )
		@view.level_links(levels)
	end

	def action_with(user)
		relationship = 0
		#relationship = current_user.relate_to(user)
		relates="/relations?user=#{user.id}"
		msg_user = "/chat/new?user=#{user.id}"
		case relationship
		when -1
			{unblock: "#{relates}&act=-1", chat_to: msg_user}
		when 1
			{request:"#{relates}&act=1", unfriend:"#{relates}&act=0", block:"#{relates}&act=-1", chat_to: msg_user}
		when 2
			{accepts:"#{relates}&act=3", block:"#{relates}&act=-1", chat_to: msg_user}
		when 3
			{unfriend:"#{relates}&act=0", block:"#{relates}&act=-1", chat_to: msg_user}
		when 4
			{profile:"/users/#{current_user.id}/edit", config:"/config/#{user.id}"}
		else # 0
			{request:"#{relates}&act=1", block:"#{relates}&act=-1", chat_to: msg_user}
		end
	end

end
