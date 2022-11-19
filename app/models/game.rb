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

  belongs_to :player_1, class_name: 'User'
  belongs_to :player_2, class_name: 'User', optional: true

  enum :status, open: 0, closed: 1

  default_scope { order(created_at: :desc) }
  scope :between, -> (a, b) { where(player_1_id: a.id, player_2_id: b.id).or(where(player_1_id: b.id, player_2_id: a.id)) }
  scope :ready, -> { unscoped.open.order(created_at: :asc).where(player_2_id: nil) }
  scope :ready_for, -> (user) { ready.where.not(player_1_id: user.id) }


  private

  def generate_uid
    self.uid = self.class.uid if self.uid.nil?
  end
end