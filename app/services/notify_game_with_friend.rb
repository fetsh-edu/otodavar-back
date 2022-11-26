class NotifyGameWithFriend
  include Interactor

  def call
    return unless context.notify

    notification = Notification.create(
      user_id: context.player.id,
      payload: Notification::PAYLOAD[:game_created].call(context.game)
    )
    if notification.persisted?
      context.notification_recepient = notification.user
      context.notification = notification
    else
      context.fail!(errors: (context.errors || []).concat(notification.errors.full_messages))
    end
  end

end
