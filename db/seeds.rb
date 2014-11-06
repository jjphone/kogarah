sql = [
	'db/plpgsql_search_user_ids_on_any_relation.sql',
	'db/plpgsql_search_user_ids_on_relation.sql',
	'db/plpgsql_search_user_ids.sql',
	'db/plpgsql_search_user_tag.sql'
]
sql.each{ |file|
	puts "Running - #{file} : ----"	
	res = ActiveRecord::Base.connection.execute(File.open(file, 'r').read)
  	puts "done !  ---- "
}


Link.destroy_all 
Link.create(display: "home", 	url: "/")
Link.create(display: "profile", url: "/users/##current_user_id##/edit", substitue: 2)
Link.create(display: "config",	url: "/config/##current_user_id##", substitue: 2)
Link.create(display: "map",		url: "/maps")

Link.create(display: "unfriend",url: "/relationships/##current_user_id##?user=##main_id##&op=0", 	method: 'put', substitue: 3)
Link.create(display: "unblock", url: "/relationships/##current_user_id##?user=##main_id##&op=-1", 	method: 'put', substitue: 3)
Link.create(display: "request",	url: "/relationships/##current_user_id##?user=##main_id##&op=1", 	method: 'put', substitue: 3)
Link.create(display: "accept", 	url: "/relationships/##current_user_id##?user=##main_id##&op=3", 	method: 'put', substitue: 3)
Link.create(display: "block", 	url: "/relationships/##current_user_id##?user=##main_id##&op=-1", 	method: 'put', substitue: 3)

Link.create(display: "users", 	url: "/users")
Link.create(display: "friends", url: "/users?type=3")
Link.create(display: "pendings", url: "/users?type=2")
Link.create(display: "requested", url: "/users?type=1")
Link.create(display: "blocked", url: "/users?type=-1")


Link.create(display: "chats", 		url: "/chats")
Link.create(display: "msg user", 	url: "/chats/new?user=##main_id##", substitue: 1)
Link.create(display: "all chats",	url: "/chats")
Link.create(display: "unread", 		url: "/chats?type=unread")
Link.create(display: "remove chat", url: "/chats/##main_id##", method: "delete", substitue: 1)
Link.create(display: "search", 		url: "/users")
p "Created #{Link.all.size} links"

def create_menu(group, key, names)
	names.to_a.each_with_index do |item, index|
	  Menu.create(group: group, key: key, order: index, link_id: Link.find_by(display: item).id )
	end
end


Menu.destroy_all
create_menu('related', 'users', ['home', 'chats', 'map'])
create_menu('related', 'chats', ['home', 'search', 'profile'])
create_menu('level', 'users#index', ['users', 'friends', 'pendings', 'blocked', 'requested'])
create_menu('level', 'realtions#own', ['profile', 'config', 'msg user'])
create_menu('level', 'relations#friend', ['unfriend', 'block', 'msg user'])
create_menu('level', 'relations#pending', ['accept', 'block', 'msg user'] )
create_menu('level', 'relations#request', ['request', 'unfriend', 'block', 'msg user'] )
create_menu('level', 'relations#block', ['unblock', 'msg user'])
create_menu('level', 'relations#stranger', ['request', 'block', 'msg user'])

p "Created #{Menu.all.size} menu items"



