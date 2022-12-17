class HomeSerializer < Panko::Serializer
  attributes :stalled_count, :total_stalled_count
  # has_many :open_games,          each_serializer: GameSerializer, except: [ :words ]
  has_many :win_games,           each_serializer: GameSerializer, except: [ :words ]
  has_many :my_turn_games,       each_serializer: GameSerializer, except: [ :words ]
  has_many :stalled_preview,     each_serializer: GameSerializer, except: [ :words ]
  has_many :closed_games,        each_serializer: GameSerializer, except: [ :words ]
  has_one :random_game,          serializer: GameSerializer, except: [ :words ]

  def stalled_count = 1 || object.stalled_preview.count
  def total_stalled_count = object.stalled_games.count

end
