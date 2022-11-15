class NotificationSerializer
  include JSONAPI::Serializer

  attributes :id, :seen, :created_at, :payload

end
