class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :rememberable,
         # :trackable,
         # :uid,
         :jwt_authenticatable, jwt_revocation_strategy: self

  def self.uid
    loop do
      token = Devise.friendly_token
      break token unless self.to_adapter.find_first({ :uid => token })
    end
  end

  before_validation do
    self.uid = self.class.uid if self.uid.nil?
  end
  before_validation(on: :create) do
    self.user_name = self.uid if self.user_name.nil?
  end
  before_save do
    self.user_name_changed_at = Time.now unless self.user_name == self.uid
  end

  validates :name, presence: true, length: { in: 2..100 }
  validates :user_name,
            uniqueness: { case_sensitive: false },
            presence: true,
            length: { in: 2..20 },
            format: { :with => /\A[a-zA-Z0-9_-]+\z/, message: "only letters, numbers, '-' and '_' are allowed" }

  validate :user_name_can_be_changed_once

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
             UsersQuery.friends(user_id: user.id, scope: true).order(:user_name)
           },
           through: :friendships

  has_many :suggested_friends_unsorted,
           ->(user) {
             User
               .unscope(where: :user_id)
               .from('friendships')
               .joins("INNER JOIN friendships f2 ON (friendships.user_id = f2.user_id OR friendships.user_id = f2.friend_id OR friendships.friend_id = f2.user_id OR friendships.friend_id = f2.friend_id)")
               .joins("INNER JOIN users u ON (f2.user_id = u.id OR f2.friend_id = u.id)")
               .where("friendships.user_id = ? OR friendships.friend_id = ?", user.id, user.id)
               .where.not(u: {id: user.id})
               .where(friendships: {confirmed: true})
               .where(f2: {confirmed: true})
               .where("u.id NOT IN (SELECT friend_id FROM friendships WHERE user_id = ? UNION SELECT user_id FROM friendships WHERE friend_id = ?)", user.id, user.id)
               .group("u.id")
               .select("COUNT(u.id) as cnt, u.id, u.name, u.user_name, u.uid, u.email, u.avatar")
           },
           class_name: 'User'

  def suggested_friends
    suggested_friends_unsorted.sort_by{|a| a.cnt * -1  }
  end

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

  has_many :seen_games,
           -> (user) {
             Game.all.unscope(where: :user_id).where(player_1_id: user.id, seen_by_1: true).or(Game.all.where(player_2_id: user.id, seen_by_2: true))
           },
           class_name: "Game",
           inverse_of: :player_1

  has_many :not_seen_games,
           -> (user) {
             Game.all.unscope(where: :user_id).where(player_1_id: user.id, seen_by_1: false).or(Game.all.where(player_2_id: user.id, seen_by_2: false))
           },
           class_name: "Game",
           inverse_of: :player_1

  has_many :push_subscriptions, dependent: :destroy


  def self.find_by_uid_or_user_name!(some)
    User.where(uid: some).or(User.where(user_name: some)).first!
  end


  def open_games = games
                     .open
                     .order_by_updated

  def win_games = not_seen_games
                    .closed
                    .order_by_updated

  def my_turn_games = open_games
                        .where("`games`.`words_count` % 2 = 0 OR `games`.`last_word_user_id` != ?", id)

  def stalled_games = open_games
                  .where("`games`.`words_count` % 2 != 0 AND `games`.`last_word_user_id` = ?", id)
  def closed_games = seen_games
                       .order_by_updated
                       .closed

  def random_game = games.where(player_2_id: nil).first

  def add_friend(user)
    outgoing_friend_requests.create(friend: user)
  end

  def common_games(user_id) = Game
                                .where(player_1_id: id, player_2_id: user_id)
                                .or(Game.where(player_2_id: id, player_1_id: user_id))

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
        message: JSON.generate(message),
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

  private

  def user_name_can_be_changed_once
    if user_name_changed? && user_name_changed_at.present?
      errors.add(:user_name, "can't change more than once")
    end
  end
end
