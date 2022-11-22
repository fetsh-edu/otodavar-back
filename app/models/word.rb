class Word < ApplicationRecord
  belongs_to :game
  belongs_to :user

  validates :round_id, uniqueness: { scope: [:game_id, :user_id] }
  validates :word, :round_id, presence: true
  validate :user_should_be_of_game, :should_be_new_or_an_answer

  private

  def should_be_new_or_an_answer
    return if round_id.zero?
    return if Word.where(game_id: game_id, round_id: round_id - 1, user_id: partner_id).any?
    errors.add(:round_id, "Should be an answer to previous word")
  end

  def user_should_be_of_game
    unless user_id.in?(partners || [])
      errors.add(:user_id, "Player should be of this game")
    end
  end

  def partners
    @partners ||= [game.player_1_id, game.player_2_id]
  end

  def partner_id
    @partner_id = partners.reject { |x| x == user_id }.first
  end
end
