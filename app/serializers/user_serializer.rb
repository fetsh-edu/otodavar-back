class UserSerializer
  include JSONAPI::Serializer
  set_id :uid
  # FastJsonapi::ObjectSerializer
  attributes :uid, :email, :avatar, :name
end
