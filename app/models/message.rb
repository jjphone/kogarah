class Message < ActiveRecord::Base
	belongs_to :user
	belongs_to :chat

	validates	:user_id, 	presence: true
	validates	:chat_id, 	presence: true


	def delete
		self.active = nil
	end

	def to_h
		{id: id, active: active, chat_id: chat_id, content: content, user: user_id, extra: extra}
	end
end
