class Users::SessionsController < Devise::SessionsController
  respond_to :json

  # skip_before_action :verify_authenticity_token
  # prepend_before_action :require_no_authentication, only: [:jwt]
  # prepend_before_action(only: [:jwt]) { request.env["devise.skip_timeout"] = true }
  protect_from_forgery unless: -> { request.format.json? }

  def jwt
    jwt = JwtVerifier.call(params[:jwt])
    user = User.find_or_create_by(email: jwt[0]["email"])
    self.resource = user
    sign_in(resource_name, resource)
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  private

  def respond_with(resource, _opts = {})
    render json: {
      status: { code: 200, message: 'Logged in successfully.' },
      data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
    }, status: :ok
  end

  def respond_to_on_destroy
    if current_user
      render json: {
        status: 200,
        message: "logged out successfully"
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
end
