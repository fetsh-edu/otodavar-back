class AddUserNameToUsers < ActiveRecord::Migration[7.0]
  class User < ApplicationRecord
  end
  def up
    add_column :users, :user_name, :string
    User.all.each do |user|
      user.update!(user_name: user.uid)
    end
    change_column_null :users, :user_name, false
    add_index :users, :user_name
  end
  def down
    remove_index :users, :user_name
    remove_column :users, :user_name, :string
  end
end
