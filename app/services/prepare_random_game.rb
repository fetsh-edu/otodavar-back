class PrepareRandomGame
  include Interactor

  def call
    if (game = Game.ready_for(context.current_user).first).present?
      game.player_2_id = context.current_user.id
      if game.save
        context.game = game
        context.notify = true
      else
        context.fail!(errors: (context.errors || []).concat(game.errors.full_messages))
      end
    elsif (game = Game.find_or_create_by(player_1_id: context.current_user.id, player_2_id: nil)).persisted?
      context.game = game
    else
      context.fail!(errors: (context.errors || []).concat(game.errors.full_messages))
    end
  end
end
