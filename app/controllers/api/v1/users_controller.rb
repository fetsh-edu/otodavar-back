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
    RequestFriendshipsService.new(from: current_user, to: user).call
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

      AcceptFriendshipService.call(friend_request)

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
    json = UserSerializer.new(
             context: {current_user: current_user},
             scope: UserSerializer.scope_builder(current_user, resource)
           ).serialize_to_json(resource)
    render json: json,
           status: :ok
  end

end
