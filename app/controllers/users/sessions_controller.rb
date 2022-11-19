class Users::SessionsController < Devise::SessionsController
  respond_to :json

  # skip_before_action :verify_authenticity_token
  # prepend_before_action :require_no_authentication, only: [:jwt]
  # prepend_before_action(only: [:jwt]) { request.env["devise.skip_timeout"] = true }
  protect_from_forgery unless: -> { request.format.json? }

  def jwt
    jwt = JwtVerifier.call(params[:jwt])
    user = User.find_or_initialize_by(email: jwt[0]["email"])
    user.avatar = jwt[0]["picture"]
    user.name = jwt[0]["name"]
    user.save
    self.resource = user
    sign_in(resource_name, resource)
    respond_with resource, location: after_sign_in_path_for(resource)
  rescue StandardError => e_
    Rails.logger.info e_.full_message
    render json: {
      status: {message: "User couldn't be logged in."}
    }, status: :unprocessable_entity
  end

  private

  def respond_with(resource, _opts = {})
    render(
      status: :ok,
      json: Panko::Response.create do |r|
        {
          status: { code: 200, message: 'Logged in successfully.' },
          data: r.serializer(resource, UserSerializer, context: { current_user: resource }, scope: { filter: :me } )
        }
      end
    )
  end

  def respond_to_on_destroy
    if current_user
      render json: {
        status: 200,
        message: "Logged out successfully"
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
end
