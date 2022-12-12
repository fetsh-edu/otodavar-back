class GameSerializer < Panko::Serializer

  attributes :uid, :status, :seen_by_1, :seen_by_2

  has_one :player_1, serializer: UserSerializer, scope: {filter: :simple}
  has_one :player_2, serializer: UserSerializer, scope: {filter: :simple}
  has_many :last_words,           each_serializer: WordSerializer
  has_many :words,                each_serializer: WordSerializer

  # def last_words
  #   object.reload.last_words.map{ |w| WordSerializer.new.serialize(w)  }
  # end
end
