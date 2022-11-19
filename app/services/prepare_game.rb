class PrepareGame
  include Interactor

  after do
    context.game.reload
  end

  def call
    if context.user_uid.present?
      prepare_game_with_player
    else
      prepare_random_game
    end
    context.fail!(message: 'There is no available game :(') unless context.game.present?
  rescue StandardError => e
    context.fail!(message: e.message)
  end

  private

  def create_game(player)
    game = Game.create(player_1_id: current_user.id, player_2_id: player.id)
    if game.persisted?
      context.game = game
    else
      context.fail!(message: "Couldn't create game")
    end
  end

  def prepare_game_with_player
    player = User.find_by_uid(context.user_uid)
    context.fail!(message: 'Player not found') if player.blank?
    context.fail!(message: 'Can\'t play with yourself') if player.uid == current_user.uid?

    game = Game.between(current_user, player).open.first
    if game.present?
      context.game = game
    else
      create_game(player)
    end
  end

  def create_random_game
    game = Game.find_or_create_by(player_1_id: current_user.id, player_2_id: nil)
    if game.persisted?
      context.game = game
    else
      context.fail!(message: 'Couldn\'t create random game' )
    end
  end

  def join_random_game(game)
    game.player_2_id = current_user.id
    if game.save
      context.game = game
    else
      context.fail!(message: 'Couldn\'t join game' )
    end
  end

  def prepare_random_game
    ready = Game.ready_for(current_user).first
    if ready.blank?
      create_random_game
    else
      join_random_game(ready)
    end
  end

  def current_user
    if context.current_user
      context.current_user
    else
      context.fail!(message: 'Current user is not provided.')
    end
  end

end
