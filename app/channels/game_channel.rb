class GameChannel < ApplicationCable::Channel
  def subscribed
    if (@game = Game.find_by_uid(params[:game]))
      stream_for @game
    end
  end
end
