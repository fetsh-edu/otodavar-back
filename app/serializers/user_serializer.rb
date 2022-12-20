class UserSerializer < Panko::Serializer

  attributes :uid, :email, :avatar, :name, :friend_status,
             :games_count, :friends_count,
             :telegram_id, :user_name, :user_name_changed_at,
             :common_open_games, :common_closed_games,

  FILTERS = {
    simple:       { only:   [ :email, :avatar, :name, :uid, :friend_status, :user_name ] },
    simple_me:    { only:   [ :email, :avatar, :name, :uid, :friend_status, :telegram_id, :user_name, :user_name_changed_at ] },
    full:         { except: [ :common_open_games, :common_closed_games ] },
    friend:       { only:   [ :email, :avatar, :name, :uid, :friend_status, :games_count, :friends_count, :user_name, :friends, :common_open_games, :common_closed_games ] },
    acquaintance: { only:   [ :email, :avatar, :name, :uid, :friend_status, :games_count, :friends_count, :user_name ] }
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

  def friend_status = cache.friend_status(object)

  def games_count = object.games.count

  def friends_count = object.friends.count

  def common_open_games
    Panko::ArraySerializer.new(
      object.common_games(cache.user_id).open,
      {
        each_serializer: GameSerializer,
        except: [ :words ],
        context: { cache: cache }
      }
    ).to_a
  end
  def common_closed_games
    Panko::ArraySerializer.new(
      object.common_games(cache.user_id).closed.limit(20),
      {
        each_serializer: GameSerializer,
        except: [ :words ],
        context: { cache: cache }
      }
    ).to_a
  end
  def self.filters_for(context, scope)
    return FILTERS[:simple] if scope.blank?
    FILTERS[scope[:filter]] || FILTERS[:simple]
  end

  has_many :friends,           each_serializer: UserSerializer, scope: { filter: :simple }
  has_many :suggested_friends, each_serializer: UserSerializer, scope: { filter: :simple }
  has_many :incoming_friends,  each_serializer: UserSerializer, scope: { filter: :simple }
  has_many :outgoing_friends,  each_serializer: UserSerializer, scope: { filter: :simple }

  private
  def cache
    context[:cache]
  end

end