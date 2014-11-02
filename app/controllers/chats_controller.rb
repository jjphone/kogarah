class ChatsController < ApplicationController

	before_action :signed_in_user

	def index
		#get list of talkers of the current user for compare updated_at
		talkers = Talker.where({user_id: current_user.id, active: 1}).includes(chat: [:latest]).paginate(page: params[:page] )
		json = talkers.map{ |t|
			c = t.chat
			c.to_h( {message: c.latest.to_h, read: t.after?(c.updated_at) } )
		}
		flashs = nil
		@view = createView("/chats", chat_html("index"), "Trainbuddy | Chats", flashs)
		@view.paginates("chats", "/chats", talkers, json)
		renderView

	end

	def show
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

end
