class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|
      t.integer :active, 	default: 1
      t.integer :user_id,	null: false

      t.string 	:display
      t.integer	:last_message

      t.timestamps
    end
  end
end