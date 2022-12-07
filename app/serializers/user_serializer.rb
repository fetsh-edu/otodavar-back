class UserSerializer < Panko::Serializer

  attributes :uid, :email, :avatar, :name, :friend_status,
             :games_count, :friends_count, :telegram_id

  FILTERS = {
    simple:       { only: [ :email, :avatar, :name, :uid, :friend_status ] },
    simple_me:       { only: [ :email, :avatar, :name, :uid, :friend_status, :telegram_id ] },
    me:           { only: [ :email, :avatar, :name, :uid, :friend_status, :friends, :incoming_friends, :outgoing_friends, :telegram_id ] },
    full:         {},
    friend:       { only: [ :email, :avatar, :name, :uid, :friend_status, :games_count, :friends_count, :friends ] },
    acquaintance: { only: [ :email, :avatar, :name, :uid, :friend_status, :games_count, :friends_count ] }
  }
  def self.scope_builder(current_user, user)
    if current_user.id == user.id
      { filter: :full }
    elsif current_user.friends_with?(user)
      { filter: :friend }
    else
      { filter: :acquaintance }
    end
  end

  def friend_status = current_user.friend_status_of(object)

  def games_count = object.games.count

  def friends_count = object.friends.count

  def self.filters_for(context, scope)
    return FILTERS[:simple] if scope.blank?
    FILTERS[scope[:filter]] || FILTERS[:simple]
  end

  has_many :friends,          each_serializer: UserSerializer, scope: { filter: :simple }
  has_many :incoming_friends, each_serializer: UserSerializer, scope: { filter: :simple }
  has_many :outgoing_friends, each_serializer: UserSerializer, scope: { filter: :simple }

  private

  def current_user
    context[:current_user]
  end

end