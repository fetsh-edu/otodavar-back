class BroadcastWordJob < ApplicationJob
  queue_as :default

  def perform(word)
    @word = word
    return nil if @word.blank?

    push = WordPush.new(@word)

    BroadcastBrowserNotificationJob.perform_later(push.opponent, push.browser_message) if push.browser_message && push.opponent
    BroadcastTelegramNotificationJob.perform_later(push.opponent.telegram_id, push.telegram_message) if push.telegram_message && push.opponent

  end
end
