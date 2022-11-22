class WordSerializer < Panko::Serializer
  attributes :word, :round_id, :player

  def player
    object.user.uid
  end

end
