class UsersController < ApplicationController

	include UsersHelper
	
	before_action :signed_in_user, 	except: [:new, :create]
	before_action :auth_user, 		only: [:edit, :update, :destroy]

	def index
		#users = User.includes(:ties).where(relationships: {user_id: [current_user.id, nil]}).where("users.id <> ?", current_user.id).paginate(page: params[:page])
		users = User.includes_tie(current_user.id, ["users.id <> ?", current_user.id] ).paginate(page: params[:page])
		list_users("/users", user_html("index"), users, "/users", nil )
		renderView
	end

	def show
		@user = User.find_by_id(params[:id])
		if @user
			user_show(@user.to_slug, flash.to_hash)
			renderView
		else	#render users - list
			flashs = { error: "Invalid user id : #{params[:id].to_i}" }
			user_list_page(flashs)
		end
	end

	def edit
		if @view 
			# insufficient priviledge by :auth_user
			renderViewWithURL(4, nil)
		else  
			@view = createView(request.fullpath, user_html("edit"), site_title(@user.name), flash.to_hash)
			#after auth_user, @user either admin or own
			@view.main = @user.to_view_main_h(nil, -5)
			renderView
		end
	end


	def update
		if @view #insufficient priviledge
			renderViewWithURL(4,nil)
		else
			if @user.update(user_params("edit"))
				@user.reload
				flashs = {success: "User profile updated"}
				user_show(@user.to_slug, flashs)
			else	#error, back to edit page
				flashs = {error: "Can't update profile"}
				@view = createView("#{@user.to_slug}/edit", user_html("edit"), site_title(@user.name), flashs )
				@view.main = @user.to_view_main_h( @user.errors_h, -5 )
			end
			renderViewWithURL(4,"update.js.erb")
		end
	end


	def new 
		@view = createView("/users/new", user_html("new"), "Trainbuddy | new",  flash.to_hash )
		@view.main = User.new.to_view_main_h(nil, 4)
		renderView
	end

	def create
		@user = User.new(user_params("create"))	
		if @user.save
			@user.reload
			sign_in @user
			flashs = {success: "User created"}
			user_show(@user.to_slug, flashs)
		else #error, back to new page
			flashs = {error: "User can't be created"}
			@view = createView("/users/new", user_html("new"), "Trainbuddy | new",  flashs)
			@view.main = @user.to_view_main_h(@user.errors_h, 4)
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
