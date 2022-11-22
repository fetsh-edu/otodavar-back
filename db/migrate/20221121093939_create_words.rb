class CreateWords < ActiveRecord::Migration[7.0]
  def change
    create_table :words do |t|
      t.references :game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :round_id
      t.string :word

      t.timestamps
    end
    add_index :words, [:game_id, :user_id, :round_id], unique: true
  end
end
