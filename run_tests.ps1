# Full test suite
bundle exec rspec

# Specific test files
bundle exec rspec spec/models/user_spec.rb
bundle exec rspec spec/controllers/game_controller_spec.rb

# Feature tests
bundle exec rspec spec/features/gameplay_spec.rb