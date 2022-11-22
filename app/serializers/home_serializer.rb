class HomeSerializer < Panko::Serializer
  has_many :open_games,          each_serializer: GameSerializer, except: [ :words ]
  has_many :closed_games,        each_serializer: GameSerializer, except: [ :words ]
  has_one :random_game,          serializer: GameSerializer, except: [ :words ]
end
