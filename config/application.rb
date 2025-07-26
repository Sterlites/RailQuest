# config/application.rb
# Modern Rails application configuration
require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module RailsQuest
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version
    config.load_defaults 7.0

    # Custom configuration for Rails Quest
    config.time_zone = 'UTC'
    
    # Job queue configuration
    config.active_job.queue_adapter = :sidekiq
    
    # Custom directories for better organization
    config.autoload_paths += %W(#{config.root}/app/services)
    config.autoload_paths += %W(#{config.root}/app/policies)
    config.autoload_paths += %W(#{config.root}/app/jobs)
    
    # Security configurations
    config.force_ssl = Rails.env.production?
    
    # Generator configurations for consistency
    config.generators do |g|
      g.test_framework :rspec,
        fixtures: false,
        view_specs: false,
        helper_specs: false,
        routing_specs: false
      g.factory_bot dir: 'spec/factories'
      g.stylesheets false
      g.javascripts false
    end
    
    # CORS configuration for API
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '/api/*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end
    
    # Custom error pages
    config.exceptions_app = self.routes
    
    # Logging configuration
    config.logger = ActiveSupport::Logger.new(STDOUT)
    config.log_level = Rails.env.production? ? :info : :debug
    
    # Cache store configuration
    config.cache_store = :redis_cache_store, {
      url: ENV['REDIS_URL'] || 'redis://localhost:6379/1'
    }
    
# Session store configuration
   config.session_store :cache_store,
     key: '_rails_quest_session',
     expire_after: 1.month
   
   # Performance configurations
   config.active_record.automatic_scope_inversing = true
   config.active_record.strict_loading_by_default = true
   
   # Mailer configuration
   config.action_mailer.default_url_options = { 
     host: ENV['HOST'] || 'localhost:3000' 
   }
   
   # File upload configurations
   config.active_storage.variant_processor = :mini_magick
   config.active_storage.queues.analysis = :low
   config.active_storage.queues.purge = :low
 end
end