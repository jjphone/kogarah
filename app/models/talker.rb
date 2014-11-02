class Talker < ActiveRecord::Base
	belongs_to :user
	belongs_to :chat
	has_many :messages, primary_key: "chat_id", foreign_key: "chat_id"

	validates	:user_id, 	presence: true
	validates	:chat_id, 	presence: true
	self.per_page = 8

	def new_messages
		messages.where!("messages.updated_at > ?", self.updated_at);
	end

	def after?(last_update)
		updated_at > last_update
	end

end
