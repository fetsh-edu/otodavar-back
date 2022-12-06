class Notification < ApplicationRecord
  belongs_to :user

  default_scope { order(created_at: :desc) }
  scope :created_before, ->(time) { where('created_at < ?', time) }
  scope :before_id, ->(id_) { where('id <= ?', id_) if id_.present? }

  ACTIONS = {
    friend_request: "friend_request",
    friend_accept: "friend_accept",
    game_created: "game_created",
    random_game_accepted: "game_accepted"
  }

  PAYLOAD = {
    friend_request: -> (from) { { action: ACTIONS[:friend_request], uid: from.uid, name: from.name } },
    friend_accept: -> (from) { { action: ACTIONS[:friend_accept], uid: from.uid, name: from.name } },
    game_created: -> (game) { { action: ACTIONS[:game_created], uid: game.uid, name: game.player_1.name } },
    random_game_accepted: -> (game) { { action: ACTIONS[:random_game_accepted], uid: game.uid, name: game.player_2.name } }
  }

  def to_message
    if payload["action"] == ACTIONS[:friend_request]
      { body: "#{payload['name']} wants to be your friend!",
        url: "/u/#{payload['uid']}"
      }
    elsif payload["action"] == ACTIONS[:friend_accept]
      { body: "#{payload['name']} accepted your friend request!",
        url: "/u/#{payload['uid']}"
      }
    elsif payload["action"] == ACTIONS[:game_created]
      { body: "#{payload['name']} started a game with you!",
        url: "/g/#{payload['uid']}"
      }
    elsif payload["action"] == ACTIONS[:random_game_accepted]
      { body: "#{payload['name']} joined your random game!",
        url: "/g/#{payload['uid']}"
      }
    else
      nil
    end
  end

  def to_telegram
    if payload["action"] == ACTIONS[:friend_request]
      "[#{escape(payload['name'])}](https://otodavar.fetsh.me/u/#{payload['uid']}) wants to be your friend\\!"
    elsif payload["action"] == ACTIONS[:friend_accept]
      "[#{escape(payload['name'])}](https://otodavar.fetsh.me/u/#{payload['uid']})  accepted your friend request\\!"
    elsif payload["action"] == ACTIONS[:game_created]
      "#{escape(payload['name'])} started a [game](https://otodavar.fetsh.me/g/#{payload['uid']}) with you\\!"
    elsif payload["action"] == ACTIONS[:random_game_accepted]
      "#{escape(payload['name'])} joined your [random game](https://otodavar.fetsh.me/g/#{payload['uid']})\\!"
    else
      nil
    end
  end

  private
  def escape(word)
    word.gsub(/([_*\[\]()~`>#+\-=|{}.!])/, '\\\\\1')
  end

end
