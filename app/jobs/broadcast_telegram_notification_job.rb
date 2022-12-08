require "telegram/bot"
class BroadcastTelegramNotificationJob < ApplicationJob
  queue_as :default

  def perform(telegram_id, message)
    return if message.blank?
    return if telegram_id.blank?

    message[:reply_markup] = Telegram::Bot::Types::InlineKeyboardMarkup.new(message[:reply_markup]) if message[:reply_markup]

    Telegram::Bot::Client
      .new(Rails.application.credentials[:telegram]).api
      .send_message({
        chat_id: telegram_id,
        parse_mode: "MarkdownV2",
        disable_web_page_preview: true
      }.merge(message))
  end

end
