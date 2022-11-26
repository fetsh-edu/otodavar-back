class PlayRandom
  include Interactor::Organizer

  organize PrepareRandomGame, NotifyRandomGameAcceptance, BroadcastNotification

end
