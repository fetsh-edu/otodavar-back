# frozen_string_literal: true
class WordPush
  ACTION_WIN = "win"
  ACTION_NOTHING = "nil"
  ACTION_READY = "ready"
  ACTION_READY_TO_START = "ready_to_start"
  ACTION_ROUND = "round"

  def initialize(word)
    @word = word
  end

  attr_accessor :word

  def browser_message
    case action
    when ACTION_NOTHING
      nil
    when ACTION_WIN
      {
        body: "🥳 Sababa! #{word.word}! You've met with #{player.name} in round #{word.round_id}",
        url: "/g/#{game.uid}"
      }
    when ACTION_READY
      {
        body: "🎮 Round #{prev_word.round_id} with #{player.name}\n#{player.name} has a word in mind for this round:\n#{word_pair(prev_round[0].word, prev_round[1].word)}",
        url: "/g/#{game.uid}"
      }
    when ACTION_READY_TO_START
      {
        body: "🎮 #{player.name} joined your game and has a word in mind",
        url: "/g/#{game.uid}"
      }
    when ACTION_ROUND
      {
        body: "🎮 Round #{word.round_id} with #{player.name}\n#{player.name} said the word, and the round is:\n#{word_pair(prev_word.word, word.word)}",
        url: "/g/#{game.uid}"
      }
    else
      nil
    end
  end

  def word_pair(w1, w2)
    "#{w1} + #{w2}"
  end

  def telegram_message
    @telegram_message ||= TelegramMessageBuilder.from_push(self)
  end

  def opponent
    @opponent ||= game.opponent(player.id)
  end

  def action
    @action ||= if opponent.nil?
                  ACTION_NOTHING
                elsif game.closed?
                  ACTION_WIN
                elsif words_count.even?
                  ACTION_ROUND
                elsif words_count.odd?
                  if player_was_last?
                    ACTION_NOTHING
                  else
                    if words_count == 1
                      ACTION_READY_TO_START
                    else
                      ACTION_READY
                    end
                  end
                else
                  ACTION_NOTHING
                end
  end

  def game
    @game ||= @word.game
  end

  def player
    @player ||= @word.user
  end

  def prev_round
    @prev_round ||= game.words.where(round_id: word.round_id - 1)
  end

  def prev_word
    # @prev_word ||= game.words.where(round_id: word.round_id - 1).order(created_at: :desc).first
    @prev_word ||= game.words.where("id < ?", word.id).order(created_at: :desc).first
  end

  private

  def player_was_last?
    return false if words_count.even?

    if words_count == 1
      player.id == game.player_1_id
    else
      prev_word.present? && player.id == prev_word.user_id
    end
  end



  def words_count
    @words_count ||= game.words.count
  end


end
