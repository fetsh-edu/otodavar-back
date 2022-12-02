class BroadcastNotification
  include Interactor

  def call
    return if [context.notification_recepient || context.notification].any?(&:blank?)

    NotificationsChannel.broadcast_to(
      context.notification_recepient,
      NotificationSerializer.new.serialize(context.notification)
    )

    # if (message = context.notification.to_message)
    #   context.notification_recepient.push_notification(message)
    # end
  end
end
