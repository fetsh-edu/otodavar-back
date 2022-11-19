class GameSerializer < Panko::Serializer

  attributes :uid, :status, :player_1, :player_2

  def player_1 = object.player_1.uid

  def player_2 = object.player_2 ? object.player_2.uid : SKIP

end
