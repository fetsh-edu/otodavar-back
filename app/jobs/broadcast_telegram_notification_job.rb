require "telegram/bot"
class BroadcastTelegramNotificationJob < ApplicationJob
  queue_as :default

  def perform(telegram_id, message)
    return if message.blank?
    return if telegram_id.blank?

    Telegram::Bot::Client
      .new(Rails.application.credentials[:telegram]).api
      .send_message(
        chat_id: telegram_id,
        text: message,
        parse_mode: "MarkdownV2",
        disable_web_page_preview: true
      )
  end

end
