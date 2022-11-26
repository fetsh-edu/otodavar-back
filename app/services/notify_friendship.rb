class NotifyFriendship
  include Interactor

  def call
    notification = Notification.create(
      user_id: context.to.id,
      payload: Notification::PAYLOAD[:friend_request].call(context.from)
    )
    if notification.persisted?
      context.notification_recepient = context.to
      context.notification = notification
    else
      context.fail!(errors: (context.errors || []).concat(notification.errors.full_messages))
    end
  end
end
