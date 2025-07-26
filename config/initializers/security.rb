# config/initializers/security.rb
# Security best practices configuration
Rails.application.configure do
  # Content Security Policy
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https, :unsafe_inline
    
    # Allow @vite/client to hot reload changes in development
    if Rails.env.development?
      policy.script_src :self, :https, :unsafe_eval
      policy.connect_src :self, :https, "ws://localhost:*", "http://localhost:*"
    end
  end
  
  # Generate CSP nonce for inline scripts
  config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
  
  # Report CSP violations
  config.content_security_policy_report_only = false
  
  # Referrer Policy
  config.referrer_policy = :strict_origin_when_cross_origin
  
  # Feature Policy
  config.permissions_policy = {
    camera: [],
    microphone: [],
    geolocation: [],
    interest_cohort: []
  }
end

# Secure headers
Rails.application.config.force_ssl = true if Rails.env.production?

# Rate limiting
class RateLimitMiddleware
  def initialize(app)
    @app = app
    @store = ActiveSupport::Cache::MemoryStore.new
  end

  def call(env)
    ip = env['REMOTE_ADDR']
    key = "rate_limit:#{ip}"
    
    requests = @store.fetch(key, expires_in: 1.minute) { 0 }
    
    if requests >= 100 # 100 requests per minute
      return [429, { 'Content-Type' => 'text/plain' }, ['Rate limit exceeded']]
    end
    
    @store.write(key, requests + 1, expires_in: 1.minute)
    @app.call(env)
  end
end