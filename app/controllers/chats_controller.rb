class ChatsController < ApplicationController

	before_action :signed_in_user

	def index
		#paginate cant cache complex join + include ???
		chats = current_user.chats.includes(:latest).where("chats.active=1").paginate(page: params[:page])
		json = chats.map { |c|
			users = c.users.map{ |u|
				u.to_h(nil, -2)
			}
			c.to_h({message: c.latest.to_h, talkers: users} )
		}
		flashs = nil
		@view = createView("/chats", chat_html("index"), "Trainbuddy | Chats", flashs)
		@view.paginates("chats", "/chats", chats, json)
		renderView
	end

	def show
	end

	def new 
	end

	def create
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
