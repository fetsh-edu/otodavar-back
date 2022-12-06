class Game < ApplicationRecord
  class << self
    def uid
      loop do
        token = Devise.friendly_token
        break token unless Game.to_adapter.find_first({ :uid => token })
      end
    end
  end

  before_save :generate_uid

  validate :cant_play_with_myself

  belongs_to :player_1, class_name: 'User'
  belongs_to :player_2, class_name: 'User', optional: true

  has_many :words, -> () { order(round_id: :desc) }, dependent: :destroy
  has_many :last_words,
           -> () { order(round_id: :desc).limit(3) },
           class_name: 'Word'

  enum :status, open: 0, closed: 1

  default_scope { order(created_at: :desc) }

  scope :between, -> (a, b) { where(player_1_id: a.id, player_2_id: b.id).or(where(player_1_id: b.id, player_2_id: a.id)) }
  scope :ready, -> { unscoped.open.order(created_at: :asc).where(player_2_id: nil) }
  scope :ready_for, -> (user) { ready.where.not(player_1_id: (user.friends.pluck(:id) << user.id)) }

  def finish
    guess = words.order(round_id: :desc).limit(2)
    Rails.logger.info guess.inspect
    return unless guess.count == 2
    return if guess.map(&:round_id).uniq.size != 1
    return if guess.map(&:word).uniq.size != 1

    closed!
  end

  def opponent(player_id)
    player_id == player_1_id ? player_2 : player_1
  end

  def link
    "https://otodavar.fetsh.me/g/#{uid}"
  end

  private

  def cant_play_with_myself
    if player_1_id == player_2_id
      errors.add(:base, :invalid, message: "You shouldn't play with yourself")
    end
  end

  def generate_uid
    self.uid = self.class.uid if self.uid.nil?
  end
end