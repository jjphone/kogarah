class Relationship < ActiveRecord::Base
	belongs_to 	:user, 		class_name: "User"
	belongs_to 	:friend, 	class_name: "User", foreign_key: "friend_id"

	validates :user_id,           presence: true
	validates :friend_id,         presence: true
	validates :status,            presence: true
	validate  :prevent_self_relation

	ALIAS 	= 5
	OWN 	= 4
	FRIEND 	= 3
	PENDING	= 2
	REQUEST	= 1
	STRANGER = 0
	BLOCKED	= -1


	def prevent_self_relation
		if user_id == friend_id
			errors.add(:friend_id, "can't be same user as owner")
		end
	end

	def reversed_status
		return Relationship.status(friend_id, user_id)
	end

	def self.status(owner_id, other_id)
		return OWN if other_id == owner_id
		return STRANGER unless res = self.relates(owner_id, other_id)
		return res.status
	end

	def self.relates(owner_id, other_id)
		find_by({user_id: owner_id, friend_id: other_id})
	end

	def to_s
		case status
		when BLOCKED
			return "Blocked"
		when REQUEST
			return "Requested"
		when PENDING
			return "Pending Acceptance"
		when FRIEND
			return	"Friends"
		end
	end


	def request(nick)
		o_relation = Relationship.relates(friend_id, user_id)
		if o_relation
			case o_relation.status
			when FRIEND
				update_relation_with(FRIEND, nick)
			when BLOCKED
				update_relation_with(REQUEST, nick)
			when REQUEST
				update_relation_with(FRIEND, nick) && o_relation.update_relation_with(FRIEND,nil)
			when PENDING
				o_relation.touch 
				update_relation_with(REQUEST, nil)
			end
		else
			create_relation(friend_id, nick)
		end
	end



	def accepts(nick)
		o_relation = Relationship.relates(friend_id, user_id)
		if o_relation
			case o_relation.status
			when BLOCKED
				update_relation_with(REQUEST, nick)
			when REQUEST
				update_relation_with(FRIEND, nick) && o_relation.update_relation_with(FRIEND, nil)
			when PENDING
				o_relation.touch
				update_relation_with(REQUEST, nick)
			when FRIEND
				update_relation_with(FRIEND, nick)
			end
		else
			create_relation(friend_id, nick)
		end
	end

	def create_relation(other_id, nick)
		if User.find_by_id(other_id)
			o_relation = Relationship.create!(user_id: other_id, friend_id: user_id, status: PENDING)
			update_relation_with(REQUEST, nick)
		else
			false
		end
	end


	def unfriend
		o_relation = Relationship.relates(friend_id, user_id)
		o_relation.destroy if o_relation && o_relation.status != BLOCKED
		destroy
	end

	def block(nick)
		if status == BLOCKED
			destroy
		else
			update_relation_with(BLOCKED, nick)
		end
	end

	def set_alias(nick)
		update_relation_with(self.status, nick)
	end

	def update_relation_with(status, nick)
		self.status = status
		self.alias_name = nick if nick
		save
	end

end
