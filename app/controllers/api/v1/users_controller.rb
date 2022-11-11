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
    respond_with user.reload
  end

  def unfriend
    user = User.find_by_uid!(params[:id])
    current_user.remove_friend(user)
    respond_with user
  end

  private

  def respond_with(resource, _opts = {})
    render json: PlayerSerializer.new(resource, {params: {current_user: current_user}}).serializable_hash[:data][:attributes],
           status: :ok
  end

end
