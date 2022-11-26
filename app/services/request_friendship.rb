class RequestFriendship
  include Interactor::Organizer

  organize CreateFriendRequest, NotifyFriendship, BroadcastNotification
end
