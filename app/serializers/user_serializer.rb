class UserSerializer
  include JSONAPI::Serializer
  set_id :uid
  # FastJsonapi::ObjectSerializer
  attributes :uid, :email, :avatar, :name
  attribute :friend_status do |user, params|
    # in here, params is a hash containing the `:current_user` key
      params[:current_user].friend_status_of(user)
  end
end
