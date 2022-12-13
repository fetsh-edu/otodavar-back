# frozen_string_literal: true
require "telegram/bot"
class TelegramMessageBuilder
  def self.from_notification(notification)
    new(notification: notification).from_notification
  end

  def self.from_push(push)
    new(push: push).from_push
  end

  def initialize(notification: nil, push: nil)
    @notification = notification
    @push = push
  end

  attr_accessor :push

  def from_notification
    return nil unless @notification

    if payload["action"] == Notification::ACTIONS[:friend_request]
      {
        text: "👥 [#{escape(payload['name'])}](https://otodavar.me/u/#{payload['uid']}) wants to be your friend"
      }
    elsif payload["action"] == Notification::ACTIONS[:friend_accept]
      {
        text: "👥 [#{escape(payload['name'])}](https://otodavar.me/u/#{payload['uid']}) accepted your friend request"
      }
    elsif payload["action"] == Notification::ACTIONS[:game_created]
      {
        text: "🎮 *#{escape(payload['name'])}* started a game with you, say your first word",
        reply_markup: one_button("Play", "https://otodavar.me/g/#{payload['uid']}")
      }
    elsif payload["action"] == Notification::ACTIONS[:random_game_accepted]
      {
        text: "🎮 *#{escape(payload['name'])}* joined your random game",
        reply_markup: one_button("Play", "https://otodavar.me/g/#{payload['uid']}")
      }
    else
      nil
    end
  end

  def from_push
    return nil unless @push

    case @push.action
    when WordPush::ACTION_NOTHING
      nil
    when WordPush::ACTION_WIN
      {
        text: "🥳 Sababa\\! *#{escape(@push.word.word)}*\nYou've met with #{escape(@push.player.name)} in round #{@push.word.round_id}",
        reply_markup: one_button("Enjoy", push.game.link)
      }
    when WordPush::ACTION_READY
      {
        text: "🎮 Round #{@push.prev_word.round_id} with #{escape(@push.player.name)}\n\n#{escape(@push.player.name)} has a word in mind for this round:\n\n#{word_pair(@push.prev_round[0].word, @push.prev_round[1].word)}",
        reply_markup: one_button("Try to guess", push.game.link)
      }
    when WordPush::ACTION_READY_TO_START
      {
        text: "🎮 *#{escape(@push.player.name)}* joined your game and has a word in mind",
        reply_markup: one_button("Say a word", push.game.link)
      }
    when WordPush::ACTION_ROUND
      {
        text: "🎮 Round #{@push.word.round_id} with #{escape(@push.player.name)}\n\n#{escape(@push.player.name)} said the word, and the round is:\n\n#{word_pair(@push.prev_word.word, @push.word.word)}",
        reply_markup: one_button("Say the next word", push.game.link)
      }
    else
      nil
    end
  end

  def word_pair(w1, w2)
    "*#{escape(w1)}* \\+ *#{escape(w2)}*"
  end

  private

  def payload
    @payload ||= @notification.payload
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

  def one_button(text, url)
    { inline_keyboard: [[{text: text, url: url}]]}
  end

  def escape(word)
    word.gsub(/([_*\[\]()~`>#+\-=|{}.!])/, '\\\\\1')
  end
end
