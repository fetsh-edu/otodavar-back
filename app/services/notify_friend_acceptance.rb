class NotifyFriendAcceptance
  include Interactor

  def call
    notification = Notification.create(
      user_id: context.request.user_id,
      payload: Notification::PAYLOAD[:friend_accept].call(context.request.friend)
    )
    if notification.persisted?
      context.notification_recepient = context.request.user
      context.notification = notification
    else
      context.fail!(errors: (context.errors || []).concat(notification.errors.full_messages))
    end
  end

end
