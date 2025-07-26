# app/middleware/request_metrics.rb
# Custom middleware for tracking game metrics
class RequestMetrics
  def initialize(app)
    @app = app
  end

  def call(env)
    start_time = Time.current
    
    status, headers, response = @app.call(env)
    
    duration = Time.current - start_time
    
    # Log slow requests
    if duration > 1.0
      Rails.logger.warn "Slow request: #{env['REQUEST_METHOD']} #{env['PATH_INFO']} took #{duration.round(2)}s"
    end
    
    # Track API usage
    if env['PATH_INFO'].start_with?('/api/')
      Rails.logger.info "API Request: #{env['REQUEST_METHOD']} #{env['PATH_INFO']} - #{status} in #{duration.round(2)}s"
    end
    
    [status, headers, response]
  end
end

# Add to application.rb
# config.middleware.use RequestMetrics