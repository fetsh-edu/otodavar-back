class PlayerSerializer
  include JSONAPI::Serializer
  set_id :uid
  # FastJsonapi::ObjectSerializer
  attributes :uid, :email, :avatar, :name
  attribute :is_friend do |user, params|
    # in here, params is a hash containing the `:current_user` key
    user.friends_with?(params[:current_user])
  end
  attribute :games_count, -> { 0 }
  attribute :friends_count, -> (user) { user.friends.count }
  attribute :friends, -> (user, params) {
    if user.friends_with?(params[:current_user]) || user.id == params[:current_user].id
      user.friends.map { |u| UserSerializer.new(u).serializable_hash[:data][:attributes] }
    else
      nil
    end
  }
end
