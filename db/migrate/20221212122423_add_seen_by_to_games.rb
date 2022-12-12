class AddSeenByToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :seen_by_1, :boolean, null: false, default: false
    add_column :games, :seen_by_2, :boolean, null: false, default: false
    Game.update_all ["seen_by_1 = ?", true]
    Game.update_all ["seen_by_2 = ?", true]
  end
end
