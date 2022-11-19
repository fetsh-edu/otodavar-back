class UserSerializer < Panko::Serializer

  attributes :uid, :email, :avatar, :name,
             :games_count, :friends_count

  FILTERS = {
    simple:       { only: [ :email, :avatar, :name, :uid ] },
    full:         {},
    friend:       { only: [ :email, :avatar, :name, :uid, :games_count, :friends_count, :friends ] },
    acquaintance: { only: [ :email, :avatar, :name, :uid, :games_count, :friends_count ] }
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