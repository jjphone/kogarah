module ChatsHelper

	def chat_html(page)
		case page
		when 'index'
			asset_path("/chats/index.html")
		when 'new'
			asset_path("/chats/new.html")
		when 'show'
			asset_path("/chats/show.html")
		end			
	end

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



end
