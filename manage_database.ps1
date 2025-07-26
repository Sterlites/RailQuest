# Create migration
rails generate migration AddNewFeature

# Reset database
rails db:drop db:create db:migrate db:seed

# Generate sample data
rails runner 'GameDataGenerator.create_sample_world'