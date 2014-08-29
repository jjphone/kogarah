module UsersHelper

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

	def associate_actions(user_id, other_id)
		relation_status = Relationship.status(user_id, other_id)
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

	def gen_links(level)
		@view.related_links( {home: "/", messages: "/chats", map: "/maps"} )
		@view.level_links(level)
	end

	def show_user(owner_id, param_str)
		#@user = User.find_by_id(shower_id)
		
		@view = initView
		if @view.parse_user( @user, param_str , user_page("show"), user_page("index") )
			gen_links( associate_actions(owner_id, @user.id) )
			posts = @user.posts.paginate(page: params[:page])
			paginate = posts.map {|p| p.to_h(@user.name, @user.avatar.url) }
			@view.parse_paginate("posts", posts, "/users/#{@user.id}", paginate )
		end
		@view.flash = flash.to_hash
		flash.clear
		renderView
	end

end


