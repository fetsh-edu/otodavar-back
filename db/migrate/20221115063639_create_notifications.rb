class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :seen, null: false, default: false
      t.json :payload

      t.timestamps
    end
  end
end
