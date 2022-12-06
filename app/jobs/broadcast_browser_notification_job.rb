class BroadcastBrowserNotificationJob < ApplicationJob
  queue_as :default

  def perform(user, message)
    return if message.blank?
    return if user.blank?

    user.push_notification(message)
  end
end
