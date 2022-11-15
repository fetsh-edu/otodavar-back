class Notification < ApplicationRecord
  belongs_to :user

  default_scope { order(created_at: :desc) }
  scope :created_before, ->(time) { where('created_at < ?', time) }
  scope :before_id, ->(id_) { where('id <= ?', id_) if id_.present? }

  PAYLOAD = {
    friend_request: -> (from) { {action: "friend_request", uid: from.uid, name: from.name } },
    friend_accept: -> (from) { {action: "friend_accept", uid: from.uid, name: from.name } }
  }

end
