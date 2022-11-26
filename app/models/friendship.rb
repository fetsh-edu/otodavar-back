class Friendship < ApplicationRecord
  # Not perfect:
  # https://stackoverflow.com/questions/37244283/how-to-model-a-mutual-friendship-in-rails

  belongs_to :user
  belongs_to :friend, class_name: 'User'

  # validates :friend_id, uniqueness: { scope: :user_id }
  # validates :user_id, uniqueness: { scope: :friend_id }
  validate :cant_add_myself
  validate :friendship_uniqueness, on: :create

  scope :between, -> (a, b) { where(user_id: a.id, friend_id: b.id).or(where(user_id: b.id, friend_id: a.id)) }

  def cant_add_myself
    if user_id == friend_id
      errors.add(:friend_id, :taken, message: "Can't add yourself as a friend")
    end
  end

  def friendship_uniqueness
    if Friendship.where(user_id: user_id, friend_id: friend_id).or(Friendship.where(friend_id: user_id, user_id: friend_id)).any?
      errors.add(:friend_id, :taken, message: "Friend request already exists")
    end
  end
end