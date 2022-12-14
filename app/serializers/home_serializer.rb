class HomeSerializer < Panko::Serializer
  has_many :open_games,          each_serializer: GameSerializer, except: [ :words ]
  has_many :closed_games,        each_serializer: GameSerializer, except: [ :words ]
  has_one :random_game,          serializer: GameSerializer, except: [ :words ]

  def cache
    context[:cache] || SerializerCache.new(context[:current_user].id)
  end
end
