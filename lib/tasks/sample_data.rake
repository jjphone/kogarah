namespace :db do 
	
	desc "fill database with dummy data"
	task populate: :environment do
		password = "123456"
		User.create!( 	name: "root user",
						email: "r@u.com",
						phone: "24681012",
						login: "root-user",
						password: password,
						password_confirmation: password 
		)

		make_users(50)
		make_post(10, 30)
		make_relations(5,8, 1, true, 0, 0) # friends - request both way
		make_relations(5,4, 1, false, 0, 11) # request / other party is pending
		
		make_relations(5,4, -1, false, 0, 23) # 1 way block

		make_relations(3,3, -1, true, 0, 30) # 2way  block
		#make_relations(3,3, -1, false, 30, 0) #block		
	end

	def make_users(n)
		n.times do |user|
			name = Faker::Name.name
			email = "u#{user}@u.com"
			login = "factory-#{user}user"
			phone = 3000000 + user
			password = "123456"
			User.create!(
				name: name, email: email, login: login, phone: phone,
				password: password, password_confirmation: password
			)
		end
	end

	def make_post(n, posts)
		users = User.all.limit n
		posts.times do 
			content = Faker::Lorem.sentence(5)
			users.each{|u| u.posts.create!(content: content) }
		end
	end

	def make_relations(a_num, o_num, status, bidirectional, a_offset=0, o_offset=0)
		users = User.offset(a_offset).limit(a_num)
		users.each { |u| 
			others = User.where("id != ?", u.id).offset(o_offset).limit(o_num)
			others.each { |o| 
				u.set_relation_with(o.id, status, nil)
				o.set_relation_with(u.id, status, nil) if bidirectional
			}
		}
	end


end