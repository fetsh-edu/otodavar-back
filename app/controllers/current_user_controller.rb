class CurrentUserController < ApplicationController
  before_action :authenticate_user!
  def index
    render(
      status: :ok,
      json: Panko::Response.create do |r|
        {
          user: r.serializer(current_user, UserSerializer, context: { current_user: current_user})
        }
      end
    )
  end
end