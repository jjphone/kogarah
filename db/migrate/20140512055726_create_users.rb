class CreateUsers < ActiveRecord::Migration
	def change
		create_table :users do |t|
			t.string :name
			t.string :login, null: false, unique: true
			t.string :email, null: false, unique: true
			t.string :phone
			t.string :password_digest
			t.string :remember_token
			t.attachment :avatar

			t.timestamps
		end
	end
end
