# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

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