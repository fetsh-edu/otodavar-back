class AcceptFriendship
  include Interactor::Organizer

  organize AcceptFriendRequest, NotifyFriendAcceptance, BroadcastNotification

end
