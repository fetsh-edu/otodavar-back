class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :uid, :email, :avatar, :name
end
