class PlayFriend

  include Interactor::Organizer

  organize PrepareGameWithFriend, NotifyGameWithFriend, BroadcastNotification

end
