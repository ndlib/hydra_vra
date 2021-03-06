class GroupsUsers < ActiveRecord::Migration
  def self.up
    create_table :groups_users, :id => false do |t|
      t.integer :group_id, :null => false
      t.integer :user_id,  :null => false
    end

    add_index :groups_users, :group_id
    add_index :groups_users, :user_id
    add_index :groups_users, [:group_id, :user_id]
  end

  def self.down
    drop_table :groups_users
  end
end
