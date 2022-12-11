require "telegram/bot"
class BroadcastTelegramNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, telegram_id, message)
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
    rescue Telegram::Bot::Exceptions::ResponseError => e
      if e.error_code == 403
        User.find(user_id).update(telegram_id: nil)
      end
  end
end
