# frozen_string_literal: true

class SerializerCache
  def self.for(obj)
    if obj.instance_of?(User)
      new(obj.id, obj)
    else
      new(obj)
    end
  end
  def initialize(user_id, user = nil )
    @user = user
    @user_id = user_id
    @players = {}
    @friend_statuses = {}
    @player_uids = {}
  end

  attr_reader :user_id, :players, :friend_statuses, :player_uids

  def player_uid(player_id)
    if (pl_ = players[player_id]).present?
      pl_["uid"]
    else
      player_uids[player_id] ||= User.where(id: player_id).limit(1).pluck(:uid).first
    end
  end

  def player(player_id)
    players[player_id] ||= begin
                             player = User.where(id: player_id).first
                             UserSerializer.new(scope: { filter: :simple }, context: { cache: self }).serialize(player)
                           end
  end

  def friend_status(opponent)
    friend_statuses[opponent.id] ||= user.friend_status_of(opponent)
  end

  def user
    @user ||= User.find(user_id)
  end

end
