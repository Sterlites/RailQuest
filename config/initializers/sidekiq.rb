# config/initializers/sidekiq.rb
# Background job configuration
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }
  
  # Retry configuration
  config.default_retries = 3
  
  # Job timeout
  config.timeout = 30
  
  # Dead job retention
  config.dead_set_size = 1000
  config.dead_timeout = 6.months
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }
end

# Sidekiq Web UI authentication
require 'sidekiq/web'

if Rails.env.production?
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(username), 
      ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])
    ) & ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(password), 
      ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"])
    )
  end
end