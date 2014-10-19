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

	def generate_links(level, related)
		@view.data.merge!({links: {level: level, related: related} })
	end

	def related_links
		[	{name: "home", url: "/", method: "get"}, 
			{name: "messages", url: "/chats", method: "get"},
			{name: "map", url: "/maps", method: "get"}	
		]
	end

	def level_links(o_id, relation)
		relate_path = "/relationships/#{current_user.id}?user=#{o_id}&op="
		msg = {name: "Chat to", url: "/chat/new?user=#{o_id}", method: "get" }
		case relation
		when 4 #own
			[	{name: "profile", url: "/users/#{current_user.id}/edit", method: "get"},
				{name: "config", url: "/config/#{current_user.id}", method: "get"} 
			]
		when 3 # friend
			[	{name: "unfriend", url: relate_path+"0", method: "put"},
				{name: "block", url: relate_path+"-1", method: "put"},
				msg 
			]
		when 2 # pending
			[	{name: "accepts", url: relate_path+"3", method: "put"},
				{name: "block", url: relate_path+"-1", method: "put"},
				msg 
			]
		when 1 # request
			[	{name: "request", url: relate_path+"1", method: "put"},
				{name: "unfriend", url: relate_path+"0", method: "put"},
				{name: "block", url: relate_path+"-1", method: "put"},
				msg 
			]				
		when -1 # block
			[	{name: "unblock", url: relate_path+"-1", method: "put"},
				msg
			]
		else #stranger
			[	{name: "request", url: relate_path+"1", method: "put"},
				{name: "block", url: relate_path+"-1", method: "put"},
				msg
			]
		end
	end

	# convert @user into View object
	def user_show(url, flashs)
		relation = current_user.related_to(@user.id)
		@view = createView(url, user_html("show"), site_title(@user.name), flashs)
		@view.main = @user.to_view_main_h( {relates: relation} , relation)
		level = level_links(@user.id, relation)
		generate_links(level, related_links)
		posts = @user.posts.paginate(page: params[:page] )
		posts_json = posts.map{ |p| p.to_h(@user.name, @user.avatar.url) }
		@view.paginates("posts", url, posts, posts_json )
		@view
	end

	# convert the users.paginate into View object
	def list_users(url, page, users, paginate_url, msg)
		@view = createView(url, page, "Trainbuddy | Users", msg)
		json = users.map{ |u|
			if u.ties.first
				u.to_h( {relates: u.ties.first.status, nick: u.ties.first.alias_name }, u.ties.first.status )
			else
				u.to_h(nil, 0)
			end
		}
		@view.paginates("users", paginate_url, users, json )
		link = "/users?type="
		level = { 	all: {name: "all", url: "/users", method: "get"}, 
					friends: {name: "friends", url: link+"3", method: "get"},
					pending: {name: "pending", url: link+"2", method: "get"},
					blocked: {name: "blocked", url: link+"-1", method: "get"},
					request: {name: "requested", url: link+"1", method: "put"}
		 }
		generate_links(level, related_links)
		@view
	end


	def user_list_page(flashs)
		users = User.includes_tie(current_user.id, ["users.id <> ?", current_user.id] ).paginate(page: 1)
		list_users("/users", user_html("index"), users, "/users", nil )
		renderViewWithURL(4,nil)
	end

end


