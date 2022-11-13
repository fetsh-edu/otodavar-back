class Api::V1::UsersController < Api::ApiController
  # protect_from_forgery with: :exception
  before_action :authenticate_user!
  respond_to :json
  def show
    resource = User.find_by_uid(params[:id])
    respond_with resource
  end

  def friend
    user = User.find_by_uid!(params[:id])
    current_user.add_friend(user)
    resource = if params[:resource].present?
                 User.find_by_uid!(params[:resource])
               else
                 user
               end
    respond_with resource.reload
  end

  def unfriend
    user = User.find_by_uid!(params[:id])
    current_user.remove_friend(user)
    resource = if params[:resource].present?
                 User.find_by_uid!(params[:resource])
               else
                 user
               end
    respond_with resource.reload
  end

  def accept
    user = User.find_by_uid!(params[:id])
    friend_request = user.outgoing_friend_requests.where(friend_id: current_user.id).first
    if friend_request.present?
      friend_request.confirmed = true
      friend_request.save
      Rails.logger.info("aaaaaaaaaaaaa #{params[:resource]}")
      resource = if params[:resource].present?
                   User.find_by_uid!(params[:resource])
                 else
                   user
                 end
      respond_with resource.reload
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  private

  def respond_with(resource, _opts = {})
    render json: PlayerSerializer.new(resource, {params: {current_user: current_user}}).serializable_hash[:data][:attributes],
           status: :ok
  end

end
