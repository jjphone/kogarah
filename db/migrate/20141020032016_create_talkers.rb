class CreateTalkers < ActiveRecord::Migration
  def change
    create_table :talkers do |t|
      t.integer :user_id, 	null: false
      t.integer :chat_id, 	null: false

      t.integer :active, 	default: 1

      t.timestamps
    end

    add_index :talkers, [:user_id, :chat_id], unique: true
    add_index :talkers, [:user_id, :active]
  end
end
