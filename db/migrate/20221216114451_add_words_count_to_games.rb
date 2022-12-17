class AddWordsCountToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :words_count, :integer
    add_column :games, :last_word_user_id, :integer
    Game.find_each do |game|
      Game.reset_counters(game.id, :words)
      game.update_columns(last_word_user_id: game.words.unscope(:order).order(created_at: :desc).pluck(:user_id).first)
    end
  end
end
