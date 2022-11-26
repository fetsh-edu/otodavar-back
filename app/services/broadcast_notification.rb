class BroadcastNotification
  include Interactor

  def call
    return if [context.notification_recepient || context.notification].any?(&:blank?)

    NotificationsChannel.broadcast_to(
      context.notification_recepient,
      NotificationSerializer.new.serialize(context.notification)
    )
  end
end
