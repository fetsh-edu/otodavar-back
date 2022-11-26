class PrepareGameWithFriend
  include Interactor

  def call
    validate_player
    if (game = Game.between(context.current_user, context.player).open.first).present?
      context.game = game
    elsif (game = Game.create(player_1_id: context.current_user.id, player_2_id: context.player.id)).persisted?
      context.game = game
      context.notify = true
    else
      context.fail!(errors: (context.errors || []).concat(["Couldn't create game"]))
    end
  end

  private

  def validate_player
    context.fail!(errors: (context.errors || []).concat(['Player should exists'])) unless context.user_uid
    context.fail!(errors: (context.errors || []).concat(["Shouldn't play with yourself"])) if context.user_uid == context.current_user.uid?

    context.player = User.find_by_uid(context.user_uid)
    context.fail!(errors: (context.errors || []).concat(['Player not found'])) if context.player.blank?
  end

end
