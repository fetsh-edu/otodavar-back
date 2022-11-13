class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  # skip_before_action :verify_authenticity_token
  protect_from_forgery unless: -> { request.format.json? }

  def create
    super
  rescue StandardError => e_
    render json: {
      status: {message: "User couldn't be created successfully. #{e_}"}
    }, status: :unprocessable_entity
  end

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        status: {code: 200, message: 'Signed up successfully.'},
        data: UserSerializer.new(resource, {params: {current_user: resource}}).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: {message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}"}
      }, status: :unprocessable_entity
    end
  end
end

