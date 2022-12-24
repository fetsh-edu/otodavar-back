class HomeSerializer < Panko::Serializer
  attributes  :stalled_games, :closed_games

  has_many :win_games,           each_serializer: GameSerializer, except: [ :words ]
  has_many :my_turn_games,       each_serializer: GameSerializer, except: [ :words ]
  has_one :random_game,          serializer: GameSerializer, except: [ :words ]

  def stalled_games = page(object.stalled_games.page(1))
  def closed_games = page(object.closed_games.page(1))

  private

  def page(items)
    { items: Panko::ArraySerializer.new(
      items,
      {
        each_serializer: GameSerializer,
        except: [ :words ],
        context: { cache: context[:cache] }
      }
    ).to_a,
      page: 1,
      total_pages: items.total_pages
    }
  end

end
