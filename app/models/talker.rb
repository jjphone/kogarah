class Talker < ActiveRecord::Base
	belongs_to :user
	belongs_to :chat
	has_many :messages, primary_key: "chat_id", foreign_key: "chat_id"

	validates	:user_id, 	presence: true
	validates	:chat_id, 	presence: true

	def new_messages
		messages.where!("messages.updated_at > ?", self.updated_at);
	end


end
