class Chat < ActiveRecord::Base
	has_many 	:talkers
	has_many	:messages, 	dependent: :destroy
	has_many 	:users, 	through: :talkers, source: :user
	belongs_to 	:latest, 	class_name: "Message", foreign_key: "last_message"

	self.per_page = 8
	default_scope -> { order('chats.updated_at DESC') }

	def self.create_chat(user, talker_ids, display, content, extra)
		c = Chat.create(display: display, user_id: user)
		m = Message.create(user_id: user, chat_id: c.id, content: content, extra: extra)
		others = talker_ids.map { |id|
			Talker.create(user_id: id, chat_id: c.id)
		}
		c.update_attribute(:last_message, m.id)
		Talker.create(user_id: user, chat_id: c.id )
	end

	def self.displayList(names)
		case names
		when 1 
			"<b>#{name[0]}</b>"
		when 2
			"<b>#{name[0]}</b> and <b>#{name[1]}</b>"
		when 3
			"<b>#{name[0]}</b>, <b>#{name[1]}</b> and <b>#{name[2]}</b>"
		else
			"<b>#{name[0]}</b>, <b>#{name[1]}</b>, <b>#{name[2]}</b> and #{name.size-3} others" 
		end
	end

	def self.ids_has_user(user)
		sql = "select c.* from chats c, talkers t where t.user_id = #{user.to_i} and c.id = t.chat_id"
		Chat.connection.select_all(sql);
	end

	def reply(user, content, extra)
		if talker(user)
			m = Message.create(user_id: user, chat_id: self.id, content: content, extra: extra)
			update_attribute(:last_message, m.id)
			t.touch
		else
			false
		end
	end

	def to_h(extra)
		{id: id, user: user_id, display: display, extra: extra}
	end

end
