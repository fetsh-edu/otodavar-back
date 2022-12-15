class WordSerializer < Panko::Serializer
  attributes :word, :round_id, :player, :id, :stamp

  def player
    cache.player_uid(object.user_id)
  end

  def cache
    if context
      context[:cache]
    else
      SerializerCache.new(object.user_id)
    end
  end

end
