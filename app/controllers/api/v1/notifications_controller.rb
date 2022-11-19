class Api::V1::NotificationsController < Api::ApiController
  before_action :authenticate_user!
  respond_to :json

  def index
    notifications = current_user.notifications.limit(100)
    respond_with(notifications)
  end

  def mark_as_seen
    notifications = current_user.notifications
    notifications.where("id <= ?", params[:id]).update_all(seen: true)
    respond_with(notifications.limit(100))
  end

  private

  def respond_with(something)
    json = if something.respond_to? :seen
             NotificationSerializer.new.serialize_to_json(something)
           else
             Panko::ArraySerializer.new(something, each_serializer: NotificationSerializer).to_json
           end
    render json: json, status: :ok
  end

end
