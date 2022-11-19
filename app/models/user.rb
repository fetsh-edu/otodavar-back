class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :rememberable,
         :trackable,
         :uid,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :notifications

  has_many :friendships,
           ->(user) {
              FriendshipsQuery
                .both_ways(user_id: user.id)
                .where(confirmed: true) },
           inverse_of: :user,
           dependent: :destroy


  has_many  :outgoing_friend_requests,
            ->() { where(confirmed: false) },
            inverse_of: :user,
            class_name: "Friendship",
            dependent: :destroy

  has_many  :incoming_friend_requests,
            ->() { where(confirmed: false) },
            inverse_of: :user,
            foreign_key: :friend_id,
            class_name: "Friendship",
            dependent: :destroy

  has_many :outgoing_friends,
           source: :friend,
           through: :outgoing_friend_requests

  has_many :incoming_friends,
           source: :user,
           through: :incoming_friend_requests

  has_many :friends,
  ->(user) {
             UsersQuery.friends(user_id: user.id, scope: true)
           },
  through: :friendships


  def add_friend(user)
    return if id == user.id
    return if friends_with?(user)
    outgoing_friend_requests.create(friend: user)
  end

  def remove_friend(user)
    return if id == user.id
    Friendship.between(user, self).delete_all
  end

  def friend_status_of(user)
    if id == user.id
      "me"
    elsif friends.exists?(user.id)
      "friend"
    elsif outgoing_friend_requests.where(friend_id: user.id).exists?
      "requested"
    elsif incoming_friend_requests.where(user_id: user.id).exists?
      "wannabe"
    else
      "unknown"
    end
  end

  def friends_with?(user)
    return false unless user.respond_to?(:id)
    friends.exists?(user.id)
  end
end
