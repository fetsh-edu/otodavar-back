# frozen_string_literal: true

class BroadcastWordNotification
  include Interactor

  def call
    return if context.word.blank?

    @word = context.word

    GameChannel.broadcast_to(@word.game, WordSerializer.new.serialize(@word))
    BroadcastWordJob.perform_later(@word)
  end
end
