class Message < ActiveRecord::Base
	belongs_to :user
	belongs_to :chat

	
	default_scope -> { order('created_at DESC') }
	self.per_page = 8

	validates	:user_id, 	presence: true
	validates	:chat_id, 	presence: true

	
	def delete
		self.active = nil
	end

	def reply(content, extra)
	end

	def to_h
		{id: id, user: user_id, active: active, content: content, extra: extra}
	end
end
