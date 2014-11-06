class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus do |t|
      t.string :group
      t.string :key
      t.integer :order
      t.integer :link_id, null: false
    end
    add_index :menus, [:group, :key]
  end
end
