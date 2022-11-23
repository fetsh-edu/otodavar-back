class Api::V1::GamesController < Api::ApiController
  # protect_from_forgery with: :exception
  before_action :authenticate_user!
  respond_to :json

  def show
    resource = Game.find_by_uid(params[:id])
    respond_with_game(resource)
  end

  def index
    render json: HomeSerializer.new.serialize_to_json(current_user),
           status: :ok
  end

  def join
    result = PrepareGame.call(params.merge(current_user: current_user))
    if result.success? && result.game.present?
      respond_with_game result.game
    else
      render json: result.message, status: :expectation_failed
    end
  end

  private

  def respond_with_game(resource)
    render json: GameSerializer.new(except: [:last_words]).serialize_to_json(resource),
           status: :ok
  end

end
