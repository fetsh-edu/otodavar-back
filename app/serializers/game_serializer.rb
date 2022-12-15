class GameSerializer < Panko::Serializer

  attributes :uid, :status, :seen_by_1, :seen_by_2, :player_1, :player_2

  def player_1
    cache.player(object.player_1_id)
  end

  def player_2
    return nil unless object.player_2_id
    cache.player(object.player_2_id)
  end

  has_many :last_words,           each_serializer: WordSerializer
  has_many :words,                each_serializer: WordSerializer

  def cache
    context[:cache]
  end
end
