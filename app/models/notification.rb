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
    friend_request: -> (from) { { action: ACTIONS[:friend_request], uid: from.user_name, name: from.name } },
    friend_accept: -> (from) { { action: ACTIONS[:friend_accept], uid: from.user_name, name: from.name } },
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

end
