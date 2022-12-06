class Api::V1::UsersController < Api::ApiController
  # protect_from_forgery with: :exception
  before_action :authenticate_user!
  respond_to :json

  def show
    resource = User.find_by_uid!(params[:id])
    respond_with resource
  end

  def update
    # TODO: HANDLE Errors
    if params[:name].present?
      current_user.update(name: params[:name])
    end
    if params.key?(:telegram_id)
      current_user.update(telegram_id: params[:telegram_id])
    end
    render json: UserSerializer.new(scope: { filter: :simple_me }, context: {current_user: current_user}).serialize_to_json(current_user.reload),
           status: :ok
  end

  def me
    render json: UserSerializer.new(scope: {filter: :simple_me}, context: {current_user: current_user}).serialize_to_json(current_user),
           status: :ok
  end

  def delete_push
    subscription_params = JSON.parse(params[:subscription] || "null" )
    if subscription_params.present?
      current_user.push_subscriptions.where(
        endpoint: subscription_params["endpoint"],
        auth_key: subscription_params['keys']['auth'],
        p256dh_key: subscription_params['keys']['p256dh'],
        ).destroy_all
    end
    render json: "ok".to_json, status: :ok
  end

  def push
    subscription_params = JSON.parse(params[:subscription] || "null" )
    if subscription_params.present?
      subscription = current_user.push_subscriptions.find_or_initialize_by(
        endpoint: subscription_params["endpoint"],
        auth_key: subscription_params['keys']['auth'],
        p256dh_key: subscription_params['keys']['p256dh'],
      )
      if subscription.save
        render json: "ok".to_json, status: :ok
      else
        render json: "not_ok".to_json, status: :unprocessable_entity
      end
    else
      render json: "ok".to_json, status: :ok
    end
  end

  def friend

    user = User.find_by_uid!(params[:id])

    RequestFriendship.call(from: current_user, to: user)
    # TODO: Handle error ^^^^

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

      AcceptFriendship.call(request: friend_request)

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
