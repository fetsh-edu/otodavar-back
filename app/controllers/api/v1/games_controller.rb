class Api::V1::GamesController < Api::ApiController
  # protect_from_forgery with: :exception
  before_action :authenticate_user!
  respond_to :json

  def join
    result = PrepareGame.call(params.merge(current_user: current_user))
    if result.success? && result.game.present?
      respond_with result.game
    else
      render json: result.message, status: :expectation_failed
    end
  end

  private

  def respond_with(resource)
    render json: GameSerializer.new.serialize_to_json(resource),
           status: :ok
  end

end
