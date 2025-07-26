# Gemfile
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

# Core Rails gems following Rails 7 conventions
gem 'rails', '~> 7.0.4'
gem 'sqlite3', '~> 1.4'  # For development/testing
gem 'puma', '~> 5.0'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 5.0'
gem 'turbo-rails'       # Modern Rails approach for SPA-like experience
gem 'stimulus-rails'    # JavaScript framework integration
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', '>= 1.4.4', require: false

# Background job processing - demonstrates Rails job system
gem 'sidekiq'
gem 'redis', '~> 4.0'

# Authentication & Authorization - Rails security best practices
gem 'devise'           # Industry standard authentication
gem 'pundit'           # Authorization policies

# Modern Rails UI components
gem 'view_component'   # Component-based UI architecture
gem 'image_processing', '~> 1.2'

# API capabilities
gem 'fast_jsonapi'     # Efficient JSON serialization

# Performance & Monitoring
gem 'pg', '~> 1.1'     # Production database
gem 'newrelic_rpm'     # Application monitoring

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'     # BDD testing framework
  gem 'factory_bot_rails' # Test data factories
  gem 'faker'           # Realistic test data
  gem 'database_cleaner-active_record'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'annotate'        # Model annotation for documentation
  gem 'bullet'          # N+1 query detection
  gem 'brakeman'        # Security scanner
  gem 'rubocop-rails'   # Code style enforcement
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'shoulda-matchers' # Additional RSpec matchers
  gem 'vcr'             # HTTP interaction recording
  gem 'webmock'
end