class Api::V1::GamesController < Api::ApiController
  # protect_from_forgery with: :exception
  before_action :authenticate_user!
  respond_to :json

  def join
    if params[:user_uid].present?
      player = User.find_by_uid(params[:user_uid])
      if player.present? && player.uid != current_user.uid?
        game = Game.between(current_user, player).open.first
        if game.present?
          respond_with(game)
        else
          game = Game.new(player_1_id: current_user.id, player_2_id: player.id)
          if game.save
            respond_with(game)
          else
            render :json => game.errors.to_json, status: :expectation_failed
          end
        end
      else
        raise ActiveRecord::RecordNotFound
      end
    else
      ready = Game.ready.first
      if ready.present?
        ready.player_2_id = current_user.id
        if ready.save
          respond_with(ready)
        else
          render :json => ready.errors.to_json, status: :expectation_failed
        end
      else
        respond_with(Game.create(player_1_id: current_user.id))
      end
    end
  end

  private

  def respond_with(resource)
    render json: GameSerializer.new.serialize_to_json(resource),
           status: :ok
  end

end
