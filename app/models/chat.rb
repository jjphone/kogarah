class Chat < ActiveRecord::Base
	has_many 	:talkers
	has_many	:messages, 	dependent: :destroy
	has_many 	:users, 	through: :talkers, source: :user
	belongs_to 	:latest, 	class_name: "Message", foreign_key: "last_message"

	self.per_page = 8
	default_scope -> { order('chats.updated_at DESC') }

	# returns the talker for the sender if message created
	def self.create_new(sender_id, talkers_str, content, extra)
		sender = User.find_by( {id: sender_id} )
		blocked = Relationship.where("status = -1 and friend_id = ?", sender.id).map(&:user_id)
		ids = talkers_str.split(",").map(&:to_i) - blocked
		if ids.empty?
			nil
		else
			c = Chat.create( user_id: sender.id )
			m = Message.create(user_id: sender.id, chat_id: c.id, content: content, extra: extra)
			talkers = User.where("id in (?)", ids)
			talkers.each{ |u|
				t = Talker.create(user_id: u.id, chat_id: c.id)
			}	
			c.update_attributes( {last_message: m.id, display: display_names(sender.login, talkers)} )
			Talker.create(user_id: sender.id, chat_id: c.id) #sender updated_at is after m.created_at
		end
	end

	def reply(sender_id, content, extra)
		m = Message.create(user_id: sender_id, chat_id: id, content: content, extra: extra )
		self.touch
		Talker.find_by({chat_id: id, user_id: sender_id}).touch
	end

	def deactive
		update_attribute(:active, nil)
		Talker.where(chat_id: id).update_all( active: nil)
		Message.where(chat_id: id).update_all( active: nil)
	end

	def self.display_names(sender, talkers)
		case talkers.size
		when 1
			"@#{sender} and @#{talkers[0].login}"
		when 2
			"@#{sender}, @#{talkers[0].login} and @#{talkers[1].login}"
		else
			"@#{sender}, @#{talkers[0].login}, @#{talkers[1].login} and #{talkers.size - 2} others"
		end
	end


	def self.ids_with_user(user)
		sql = "select c.* from chats c, talkers t where t.user_id = #{user.to_i} and c.id = t.chat_id"
		Chat.connection.select_all(sql);
	end


	def to_h(extra)
		{id: id, user: user_id, display: display, extra: extra}
	end

end
