Rails.application.config.middleware.insert_before 0, Rack::Cors do
  # allow do
  #   origins '*'
  #   resource '*', headers: :any, methods: [:get, :post, :patch, :put]
  # end
  allow do
    origins '*'
    resource '/public/*', headers: :any, methods: :get

    # Only allow a request for a specific host
    resource '/api/v1/*',
             headers: :any,
             expose: ["Authorization"],
             methods: [:get, :patch, :put, :delete, :post, :options, :show]
             # if: proc { |env| env['HTTP_HOST'] == 'api.example.com' }
  end
end