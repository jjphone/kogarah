module UsersHelper

	def user_html(page)
		case page 
		when 'new'
			asset_path("/users/new.html")
		when 'show'
			asset_path("/users/show.html")
		when 'edit'
			asset_path("/users/edit.html")
		else
			asset_path("/users/index.html")
		end
	end

	def page_links(level)
		@view.data.merge!( {level: level, related: {home: "/", messages: "/chats", map: "/maps"}} )
	end


	def associate_actions(user_id, other_id)
		
		# relation_status = Relationship.status(user_id, other_id)
		# or 
		# 	use in non - signin 
		relation_status = (user_id && other_id) ?  Relationship.status(user_id, other_id) : 0

		relates = "/relationships?user=#{other_id}"
		msg_user = "/chat/new?user=#{other_id}"
		case relation_status
		when 4 # own
			{ profile: "/users/#{user_id}/edit", config: "/config/#{user_id}"}
		when 3 # friend
			{ unfriend: "#{relates}&op=0", block: "#{relates}&op=-1", chat_to: msg_user }
		when 2 # pending
			{ accepts: "#{relates}&op=3", block: "#{relates}&op=-1", chat_to: msg_user }
		when 1 # request
			{ request: "#{relates}&op=1", unfriend: "#{relates}&op=0", block: "#{relates}&op=-1", chat_to: msg_user }
		when -1 # block
			{ unblock: "#{relates}&op=-1", chat_to: msg_user }
		else #stranger
			{ request: "#{relates}&op=1", block: "#{relates}&op=-1", chat_to: msg_user }
		end
	end

	# convert @user into View object
	# for userController and relationCOntroller
	def show_user(owner_id, url, page, msg)
		@view = createView( url, page, nil, msg )
		@view.user_main(@user)
		page_links( associate_actions(owner_id, @user.id) )
		posts = @user.posts.paginate(page: params[:page] )
		posts_json = posts.map{ |p| p.to_h(@user.name, @user.avatar.url) }
		@view.paginates("posts", url, posts, posts_json )
		@view
	end


	# convert the users.paginate into View object
	# for userController and relationCOntroller
	def list_users(url, page, users, paginate_url, msg)
		@view = createView(url, page, "Trainbuddy | Users", msg)
		@view.paginates("users", paginate_url, users, users.map(&:to_h ) )
		page_links( {all:"/users", friends:"/users?type=3", pending:"/users?type=2", blocked:"/users?type=-1", requested:"/users?type=1"} )
		@view
	end


end


