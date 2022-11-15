class AcceptFriendshipService < ApplicationService

  def initialize(request)
    @request = request
  end

  attr_reader :request

  def call
    request.confirmed = true
    if request.save
      Notification.create(
        user_id: request.user_id,
        payload: Notification::PAYLOAD[:friend_accept].call(request.friend)
      )
    end
  end

  private

end
