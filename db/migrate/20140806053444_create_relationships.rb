class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer 	:user_id
      t.integer		:friend_id
      t.integer		:status
      t.string		:alias_name

      t.timestamps
    end
    add_index	:relationships, :user_id
    add_index	:relationships, :friend_id
    add_index	:relationships,	[:user_id, :friend_id], unique: true
  end
end
