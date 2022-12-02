class CreatePushSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :push_subscriptions do |t|
      t.string :endpoint
      t.string :auth_key
      t.string :p256dh_key
      t.belongs_to :user

      t.timestamps
    end
  end
end
