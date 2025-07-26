# config/initializers/cors.rb
# CORS configuration for API access
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins Rails.env.development? ? '*' : ENV['ALLOWED_ORIGINS']&.split(',')
    
    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: false
  end
end