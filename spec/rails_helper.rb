# spec/rails_helper.rb
# RSpec configuration with best practices
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'factory_bot_rails'
require 'capybara/rails'
require 'capybara/rspec'

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # Database cleaner configuration
  config.use_transactional_fixtures = false
  config.include DatabaseCleaner::ActiveRecord

  # Factory Bot integration
  config.include FactoryBot::Syntax::Methods

  # Devise helpers for authentication in tests
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::Integration
  config.include Devise::Test::IntegrationHelpers, type: :request
 config.include Warden::Test::Helpers

 # Filter lines from Rails gems in backtraces
 config.filter_rails_from_backtrace!

 # Capybara configuration
 config.include Capybara::DSL

 # Custom helper methods
 config.include RequestSpecHelper, type: :request
 config.include ControllerSpecHelper, type: :controller

 # Database cleaner hooks
 config.before(:suite) do
   DatabaseCleaner.clean_with(:truncation)
 end

 config.before(:each) do
   DatabaseCleaner.strategy = :transaction
 end

 config.before(:each, :js => true) do
   DatabaseCleaner.strategy = :truncation
 end

 config.before(:each) do
   DatabaseCleaner.start
 end

 config.after(:each) do
   DatabaseCleaner.clean
 end

 # Pundit helper
 config.include Pundit::Authorization, type: :controller
end

# Shoulda Matchers configuration
Shoulda::Matchers.configure do |config|
 config.integrate do |with|
   with.test_framework :rspec
   with.library :rails
 end
end