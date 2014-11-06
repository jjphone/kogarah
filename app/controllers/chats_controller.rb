class ChatsController < ApplicationController

	before_action :signed_in_user

	def index
		list_chats(nil)
		renderView
	end

	def show
		chat_id = params[:id].to_i
		chat = Chat.find_by(id: chat_id)
		err_msg = nil
		if chat 
			if talker = Talker.find_by(chat_id: chat.id, user_id: current_user.id)
				show_chat(chat, nil)
				talker.touch
			else
				err_msg = "User is not in the chat group"
			end
		else
			err_msg = "No active chat found with id = #{chat_id}"
		end


		if err_msg 
			list_chats({error: err_msg})
			renderViewWithURL(4,nil)
		else
			renderView
		end
	end

	def new 
	end

	def create
		message = params[:content]
		to = params[:to]
		chat = Chat.create_new(current_user.id, to, content, nil)

	end

	def update
	end

	def destroy
	end

private 

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

	def list_chats(flashs)
		#get list of talkers of the current user for compare updated_at
		talkers = Talker.where({user_id: current_user.id, active: 1}).includes(chat: [:latest]).paginate(page: params[:page] )
		json = talkers.map{ |t|
			t.chat.to_h( {message: t.chat.latest.to_h, read: t.after?(t.chat.updated_at) } )
		}
		@view = createView("/chats", chat_html("index"), site_title("Chats"), flashs)
		@view.paginates("chats", "/chats", talkers, json)
	end

	def show_chat(chat, flash)
		messages = chat.messages.includes(:user).paginate(page: params[:page])
		json = messages.map{ |m|
			m.to_h({avatar_url: m.user.avatar.url, login: m.user.login })
		}
		path = "/chats/#{chat.id}"
		@view = createView(path, chat_html("show"), site_title("Chat ##{chat.id}"), flash)
		@view.paginates("messages", path, messages, json )
	end

end
