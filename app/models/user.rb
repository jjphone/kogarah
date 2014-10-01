class User < ActiveRecord::Base
	has_many :posts, 			dependent: :destroy
	has_many :relationships, 	dependent: :destroy
	has_many :reverse_relationships, dependent: :destroy
	has_many :others, 			through: :relationships, source: :friend_id
	# , -> { where ("relationships.status=3") }

	has_attached_file :avatar, :styles => { :medium => "150x150", :thumb => "50x50#" }, 
                      #:default_url => "/images/avatar.png",
                      :default_url => "/assets/avatar.png",
                      :path => ":rails_root/public/images/:id/:style.:extension",
                      :url =>  "/images/:id/:style.:extension"

	before_save   { 
		self.email.downcase!
		self.name.capitalize!
	}
  
	before_create :create_remember_token
	
	before_validation {
		self.login = self.login.downcase.parameterize if self.login
	}

	has_secure_password

	self.per_page = 8

	# validations #
	email_regex =   /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	phone_regex =   /\A[+|-]*\d+\z/i
	login_regex =   /\A[a-z][a-z0-9]*(-){1}[a-z0-9]+\z/i

	validates :name, 	presence:		true,	
						length:			{ within: 6...50 }

	validates :email,	presence:		true,
						length:			{ within: 6...100},
						format:			{ with: email_regex },	
						uniqueness:		{ case_sensitive: false }


	validates :login, 	presence:		true,
						length: 		{ within: 6...50},
						uniqueness:		{ case_sensitive: false},
						format:			{ with: login_regex }

	validates :phone, 	uniqueness:		{ case_sensitive: false },
						format:			{ with: phone_regex },
						length:			{ within: 6...20}

	validates_attachment :avatar, 	content_type: {content_type: /^image\/(png|gif|jpeg|jpg)/, 
											message: '(png, gif, jpg or jpeg) format only' },
  									size: { in: 0..500.kilobytes, message: 'required < 500kb' }

	validates :password, length:          { within: 6...50}

	after_validation { self.errors.messages.delete(:password_digest) }


	ALIAS 	= 5
	OWN 	= 4
	FRIEND 	= 3
	PENDING	= 2
	REQUEST	= 1
	STRANGER = 0
	BLOCKED	= -1


	def to_h(extra=nil)
		return { id: id, name: name, login: login, email: email, phone: phone, avatar_url: avatar.url, extra: extra}
	end

	def User.new_remember_token
		begin 
			remember_token = SecureRandom.urlsafe_base64
		end while User.exists?( remember_token: User.digest(remember_token) )
		remember_token
	end

	def User.digest(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	def related_to(other_id)
		Relationship.status(id, other_id)
	end

	def set_relation_with(other_id, action, nick)
		return OWN if other_id == id
		relation = Relationship.new(user_id: id, friend_id: other_id) unless relation = Relationship.relates(id, other_id)

		case action
		when ALIAS
			relation.set_alias(nick)
		when FRIEND
			relation.accepts(nick)
		when REQUEST
			relation.request(nick)
		when STRANGER
			relation.unfriend
		when BLOCKED
			relation.block(nick)
		end
	end

	def to_slug
		# login ?	"/u/#{login}" : "/users/#{id}"
		"/users/#{id}"
	end

private

	def create_remember_token
		self.remember_token = User.digest(User.new_remember_token)
	end

=begin
    def person_params
      # It's mandatory to specify the nested attributes that should be whitelisted.
      # If you use `permit` with just the key that points to the nested attributes hash,
      # it will return an empty hash.
      	params.require(:person).permit(:name, :age, pets_attributes: [ :name, :category ])
    end
=end

end
