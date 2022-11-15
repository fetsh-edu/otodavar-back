class Friendship < ApplicationRecord
  # Not perfect:
  # https://stackoverflow.com/questions/37244283/how-to-model-a-mutual-friendship-in-rails

  belongs_to :user
  belongs_to :friend, class_name: 'User'

  scope :between, -> (a, b) { where(user_id: a.id, friend_id: b.id).or(where(user_id: b.id, friend_id: a.id)) }

end
