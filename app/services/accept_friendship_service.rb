class AcceptFriendshipService < ApplicationService

  def initialize(request)
    @request = request
  end

  attr_reader :request

  def call
    request.confirmed = true
    if request.save
      payload = Notification::PAYLOAD[:friend_accept].call(request.friend)
      notification = Notification.create(
        user_id: request.user_id,
        payload: payload
      )
      if notification.persisted?
        NotificationsChannel.broadcast_to(request.user, NotificationSerializer.new(notification).serializable_hash[:data][:attributes])
      end
    end
  end

  private

end
