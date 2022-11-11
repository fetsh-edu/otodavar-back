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

  has_many :friendships,
           ->(user) { FriendshipsQuery.both_ways(user_id: user.id) },
           inverse_of: :user,
           dependent: :destroy

  has_many :friends,
           ->(user) { UsersQuery.friends(user_id: user.id, scope: true) },
           through: :friendships

  def add_friend(user)
    return if id == user.id
    return if friends_with?(user)
    friends << user
  end

  def remove_friend(user)
    return if id == user.id
    friends.delete(user)
  end

  def friends_with?(user)
    return false unless user.respond_to?(:id)
    friends.exists?(user.id)
  end
end
