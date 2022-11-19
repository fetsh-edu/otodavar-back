class NotificationSerializer < Panko::Serializer
  attributes :id, :seen, :created_at, :payload
end
