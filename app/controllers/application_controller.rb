class ApplicationController < ActionController::Base
  handle_api_errors

  def error404
    raise ActionController::RoutingError.new(request.path)
  end
end
