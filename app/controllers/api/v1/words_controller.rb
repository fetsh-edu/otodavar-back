class Api::V1::WordsController < Api::ApiController
  # protect_from_forgery with: :exception
  before_action :authenticate_user!
  respond_to :json

  def create
    @game = Game.find_by_uid(params[:game_uid])
    @word = @game.words.create(word_params.merge({user_id: current_user.id}))
    if @word.persisted?
      GameChannel.broadcast_to(@game, WordSerializer.new.serialize(@word))

      # if @game.closed?
      #   message = { body: "#{current_user.name} matched your word!",
      #     url: "/g/#{@game.uid}"
      #   }
      #   @game.opponent(current_user.id).push_notification(message)
      # else
      #   message = { body: "#{current_user.name} has a word for you to match!",
      #     url: "/g/#{@game.uid}"
      #   }
      #   @game.opponent(current_user.id).push_notification(message)
      # end

      respond_with_game(@game.reload)
    else
      #  TODO: else handle errors
      render json: @game.errors, status: :expectation_failed
    end
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
