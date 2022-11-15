class RequestFriendshipsService < ApplicationService

  def initialize(from:, to:)
    @from = from
    @to = to
  end

  attr_reader :from, :to

  def call
    from.add_friend(to)
    notification = Notification.create(
      user_id: to.id,
      payload: Notification::PAYLOAD[:friend_request].call(from)
    )
    if notification.present?
      NotificationsChannel.broadcast_to(to, NotificationSerializer.new(notification).serializable_hash[:data][:attributes])
    end
  end

  private

end
