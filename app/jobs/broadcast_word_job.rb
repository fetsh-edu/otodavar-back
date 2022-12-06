class BroadcastWordJob < ApplicationJob
  queue_as :default

  def perform(word)
    @word = word

    message = if game.closed?
                { body: "Sababa! #{player.name} matched your word: #{@word.word}!", url: "/g/#{game.uid}" }
              elsif (opposite = @word.opposite).present?
                { body: "#{player.name} said #{@word.word} to your #{opposite.word}!", url: "/g/#{game.uid}" }
              else
                { body: "#{player.name} has a word for you to match!", url: "/g/#{game.uid}" }
              end

    tg_message = if game.closed?
                   "Sababa\\! [#{escape(player.name)} matched](#{game.link}) your word: *#{escape(@word.word)}*\\!"
                 elsif (opposite = @word.opposite).present?
                   "[#{escape(player.name)} said](#{game.link}) *#{escape(@word.word)}* to your *#{escape(opposite.word)}*\\!"
                 else
                   "[#{escape(player.name)} has a word](#{game.link}) for you to match\\!"
                 end

    BroadcastBrowserNotificationJob.perform_later(opponent, message) if opponent.present?
    BroadcastTelegramNotificationJob.perform_later(opponent.telegram_id, tg_message) if opponent.present?
  end

  private

  def escape(word)
    word.gsub(/([_*\[\]()~`>#+\-=|{}.!])/, '\\\\\1')
  end

  def opponent
    @opponent ||= game.opponent(player.id)
  end

  def game
    @game ||= @word.game
  end

  def player
    @player ||= @word.user
  end
end
