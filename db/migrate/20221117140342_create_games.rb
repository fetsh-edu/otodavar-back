class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.integer :player_1_id, null: false
      t.integer :player_2_id
      t.string :uid, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
