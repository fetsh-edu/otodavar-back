class AddUserNameChangetAtToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :user_name_changed_at, :datetime
  end
end
