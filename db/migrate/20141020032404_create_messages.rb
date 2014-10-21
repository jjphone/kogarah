class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :user_id, 	null: false
      t.integer :chat_id,	null: false
      t.integer :active, 	default: 1

      t.string 	:content
      t.string 	:extra

      t.timestamps
    end
    add_index :messages, [:user_id, :chat_id], unique: true
    add_index :messages, [:chat_id, :active]
  end
end
