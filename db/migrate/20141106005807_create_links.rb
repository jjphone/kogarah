class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :display
      t.string :method, 		default: 'get'
      t.string :url, 			null: false
      t.integer :substitue
    end
  end
end
