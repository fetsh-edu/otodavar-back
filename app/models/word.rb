class Word < ApplicationRecord
  belongs_to :game, touch: true, counter_cache: true
  belongs_to :user

  enum :stamp,
       nothing: 0,
       lol: 1,
       omg: 2,
       wtf: 3,
       almost: 4,
       aaaaa: 5,
       monkey: 6,
       love: 7,
       party: 8,
       buthow: 9


  validates :round_id, uniqueness: { scope: [:game_id, :user_id] }
  validates :word, :round_id, presence: true
  validate :user_should_be_of_game, :should_be_new_or_an_answer

  before_save :normalize_word
  after_save :mark_game


  def opposite
    Word.where(game_id: game_id, round_id: round_id).where.not(id: id).first
  end


  private

  def normalize_word
    self.word = self.word.upcase.strip
  end
  def mark_game
    game.on_word_created(self)
    true
  end
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
