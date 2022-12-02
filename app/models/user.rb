class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :rememberable,
         # :trackable,
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

  has_many :outgoing_games,
           class_name: "Game",
           foreign_key: :player_1_id,
           dependent: :destroy

  has_many :incoming_games,
           class_name: "Game",
           foreign_key: :player_2_id,
           dependent: :destroy

  has_many :games,
           -> (user) {
             Game.all.unscope(where: :user_id).where(player_1_id: user.id).or(Game.all.where(player_2_id: user.id))
           },
           inverse_of: :player_1,
           dependent: :destroy

  has_many :push_subscriptions, dependent: :destroy

  def open_games = games.open.includes(:player_2, :player_1)
  def closed_games = games.closed.includes(:player_1, :player_2).limit(50)
  def random_game = games.where(player_2_id: nil).includes(:player_1).first

  def add_friend(user)
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

  def push_notification(message = 'Message from oto | davar')
    subs = self.push_subscriptions.reload
    return if subs.empty?

    subs.each do |sub|
      Webpush.payload_send(
        message: message,
        endpoint: sub.endpoint,
        p256dh: sub.p256dh_key,
        auth: sub.auth_key,
        vapid: {
          public_key: Rails.application.credentials.dig(:vapid, :public_key),
          private_key: Rails.application.credentials.dig(:vapid, :private_key)
        },
        ssl_timeout: 5,
        open_timeout: 5,
        read_timeout: 5
      )
    rescue Webpush::ExpiredSubscription => e_
      sub.destroy
    end
  end
end
