class Game < ApplicationRecord
  class << self
    def uid
      loop do
        token = Devise.friendly_token
        break token unless Game.to_adapter.find_first({ :uid => token })
      end
    end
  end

  paginates_per 5

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

  scope :order_by_updated, -> { unscope(:order).order(updated_at: :desc) }

  scope :between, -> (a, b) { where(player_1_id: a.id, player_2_id: b.id).or(where(player_1_id: b.id, player_2_id: a.id)) }
  scope :ready, -> { unscoped.open.order(created_at: :asc).where(player_2_id: nil) }
  scope :ready_for, -> (user) { ready.where.not(player_1_id: (user.friends.pluck(:id) << user.id)) }

  def on_word_created(word)
    self.last_word_user_id = word.user_id
    finish
    save
  end

  def finish
    return unless words_count % 2 == 0

    self.status = 'closed' if words
                               .order(round_id: :desc)
                               .limit(2)
                               .map { |w| [ w.round_id, w.word ] }
                               .uniq
                               .size == 1
  end

  def opponent(player_id)
    player_id == player_1_id ? player_2 : player_1
  end

  def of_player?(player_id)
    [player_1_id, player_2_id].include?(player_id)
  end

  def link
    "https://otodavar.me/g/#{uid}"
  end

  def to_message
    words_ = words.group_by(&:round_id).map{|k, v| "#{k}: #{v.map(&:word).join(" -- ")}"  }.join("\n")
    "GAME: #{player_1.name} vs #{player_2.name}\n\n#{words_}"
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