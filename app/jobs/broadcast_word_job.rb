class BroadcastWordJob < ApplicationJob
  queue_as :default

  def perform(word)
    @word = word
    return nil if @word.blank?

    push = WordPush.new(@word)

    BroadcastBrowserNotificationJob.perform_later(push.opponent, push.browser_message) if push.browser_message && push.opponent

    return unless push.telegram_message.present? && push.opponent && push.opponent.telegram_id.present?

    BroadcastTelegramNotificationJob.perform_later(push.opponent.id, push.opponent.telegram_id, push.telegram_message)
  end
end
