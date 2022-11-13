class PlayerSerializer
  include JSONAPI::Serializer
  set_id :uid
  # FastJsonapi::ObjectSerializer
  attributes :uid, :email, :avatar, :name
  attribute :friend_status do |user, params|
    # in here, params is a hash containing the `:current_user` key
    params[:current_user].friend_status_of(user)
  end
  attribute :games_count, -> { 0 }
  attribute :friends_count, -> (user) { user.friends.count }
  attribute :friends, -> (user, params) {
    if user.friends_with?(params[:current_user]) || user.id == params[:current_user].id
      user.friends.map{|u| simple_user(u, params[:current_user])}
    else
      []
    end
  }
  attribute :incoming_friend_requests, -> (user, params) {
    if user.id == params[:current_user].id
      user.incoming_friend_requests.map(&:user).map{|u| simple_user(u, params[:current_user])}
    else
      []
    end
  }
  attribute :outgoing_friend_requests, -> (user, params) {
    if user.id == params[:current_user].id
      user.outgoing_friend_requests.map(&:friend).map{|u| simple_user(u, params[:current_user])}
    else
      []
    end
  }
  def self.simple_user(u, current_user)
    UserSerializer.new(u, {params: {current_user: current_user}}).serializable_hash[:data][:attributes]
  end
end
