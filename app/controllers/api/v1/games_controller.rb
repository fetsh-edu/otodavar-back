class Api::V1::GamesController < Api::ApiController
  # protect_from_forgery with: :exception
  before_action :authenticate_user!
  respond_to :json

  def show
    resource = Game.find_by_uid!(params[:id])
    respond_with_game(resource)
  end

  def index
    render json: HomeSerializer.new(context: {current_user: current_user, cache: SerializerCache.new(current_user.id, current_user)}).serialize_to_json(current_user),
           status: :ok
  end

  def archive
    resource = Game.find_by_uid!(params[:id])

    if resource.player_1_id == current_user.id
      resource.update(seen_by_1: true)
    elsif resource.player_2_id == current_user.id
      resource.update(seen_by_2: true)
    end

    respond_with_game(resource)
  end

  def join
    result = if params[:user_uid].present?
                PlayFriend.call(params.merge(current_user: current_user))
             else
                PlayRandom.call(params.merge(current_user: current_user))
             end
    if result.success? && result.game.present?
      respond_with_game result.game
    else
      render json: result.errors, status: :expectation_failed
    end
  end

  private

  def respond_with_game(resource)
    render json: GameSerializer.new(except: [:last_words], context: {current_user: current_user}).serialize_to_json(resource),
           status: :ok
  end

end
