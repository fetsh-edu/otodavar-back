class BroadcastNotification
  include Interactor

  def call
    return if [context.notification_recepient || context.notification].any?(&:blank?)

    NotificationsChannel.broadcast_to(
      context.notification_recepient,
      NotificationSerializer.new.serialize(context.notification)
    )
    if (message = context.notification.to_message)
      BroadcastBrowserNotificationJob.perform_later(context.notification_recepient, message)
    end
    if (message = TelegramMessageBuilder.from_notification(context.notification))
      BroadcastTelegramNotificationJob.perform_later(context.notification_recepient.telegram_id, message)
    end
  end
end
