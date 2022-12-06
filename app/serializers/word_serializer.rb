class WordSerializer < Panko::Serializer
  attributes :word, :round_id, :player, :id, :stamp

  def player
    object.user.uid
  end

end
