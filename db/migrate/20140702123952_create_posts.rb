class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer   :user_id
      t.string    :content
      t.string    :extra
      t.datetime  :s_time
      t.datetime  :e_time
      t.datetime  :expire
      t.integer   :message_id

      t.timestamps
    end
    add_index     :posts, [:user_id, :created_at]
    add_index     :posts, [:user_id, :expire]
  end
end
