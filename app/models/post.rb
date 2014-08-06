class Post < ActiveRecord::Base
	belongs_to :user
	default_scope -> { order('created_at DESC') }

	validates :user_id, 	presence: true
	validates :content, 	presence: true, length: {within: 1... 1000 }
	
	self.per_page = 8

	def to_h(name, img_url)
		return {id: id, user_id: user_id, name: name, avatar_url: img_url, \
			msg_id: message_id, content: content, extra: extra, \
			updated_at: updated_at_in_words, expire: syd_time(expire), s_time: s_time, e_time: e_time }
	end

#private
	def updated_at_in_words
		syd_time = updated_at.in_time_zone("Sydney")
		syd_time.today? ? syd_time.strftime("%I:%M:p") : syd_time.strftime("%m.%d %H:%M")
	end

	def syd_time(t)
		t ?	t.in_time_zone("Sydney").strftime("%-m.%-d %H:%M") : nil

	end

end
