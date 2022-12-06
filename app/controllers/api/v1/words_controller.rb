class Api::V1::WordsController < Api::ApiController
  # protect_from_forgery with: :exception
  before_action :authenticate_user!
  respond_to :json

  def create
    @game = Game.find_by_uid(params[:game_uid])
    @word = @game.words.create(word_params.merge({user_id: current_user.id}))
    if @word.persisted?
      BroadcastWordNotification.call(word: @word)
    end
    respond_with_game(@game.reload)
  end

  def stamp
    @word = Word.find(params[:id])
    if Word.stamps.keys.include?(params[:stamp]) && @word.game.of_player?(current_user.id)
      @word.stamp = params[:stamp]
      if @word.save
        GameChannel.broadcast_to(@word.game, WordSerializer.new.serialize(@word))
      end
    end
    # TODO:
    render json: nil.to_json, status: :ok
  end

  def respond_with_game(resource)
    render json: GameSerializer.new(except: [:last_words], context: {current_user: current_user}).serialize_to_json(resource),
           status: :ok
  end

  private

  def word_params
    params.require(:word).permit([:round_id, :word])
  end
end
