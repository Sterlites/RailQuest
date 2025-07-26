# Rails Quest - Educational RPG Game

## Overview
Rails Quest is a comprehensive single-player RPG game built with Ruby on Rails, designed to demonstrate the framework's core capabilities and best practices. This project serves as both an engaging game and an educational resource for developers learning Rails.

## Features Demonstrated

### Core Rails Concepts
- **MVC Architecture**: Clear separation of concerns with models, views, and controllers
- **RESTful Routing**: Standard REST patterns for resource management
- **ActiveRecord ORM**: Complex associations, validations, and query optimization
- **Migrations**: Database schema management and versioning
- **Callbacks**: Automated business logic triggers

### Advanced Patterns
- **Service Objects**: Business logic encapsulation
- **Background Jobs**: Asynchronous processing with Sidekiq
- **Authorization**: Role-based access control with Pundit
- **API Development**: JSON:API compliant endpoints
- **Testing**: Comprehensive test coverage with RSpec

### Modern Rails Features
- **Stimulus Controllers**: Unobtrusive JavaScript patterns
- **Turbo Frames**: SPA-like experience without complexity
- **ViewComponent**: Component-based UI architecture
- **ActionCable**: Real-time features (WebSocket support)
- **ActiveStorage**: File upload handling

## Architecture

### Models
- **User**: Core player entity with authentication and game stats
- **GameSession**: Manages active game state and location
- **Location**: Game world areas with connections and items
- **Item**: Equipment, consumables, and quest items
- **Quest**: Mission system with objectives and rewards
- **CombatLog**: Battle history and statistics

### Controllers
- **GameController**: Main game interface and actions
- **HomeController**: Dashboard and user management
- **QuestsController**: Quest management and progression
- **InventoryController**: Item management interface
- **API Controllers**: RESTful API endpoints

### Services
- **CombatService**: Battle mechanics and resolution
- **QuestService**: Quest completion and rewards
- **LevelUpService**: Character progression logic

### Jobs
- **LevelUpRewardJob**: Asynchronous reward processing
- **LocationEntryJob**: Area transition effects
- **ItemUseJob**: Complex item usage handling

## Game Mechanics

### Character System
- Level-based progression (1-100)
- Health and Mana resource management
- Attack and Defense calculations
- Equipment slot system

### Combat System
- Turn-based combat with variance
- Level-appropriate enemy scaling
- Experience and gold rewards
- Death penalties and recovery

### Quest System
- Objective-based missions
- Progress tracking and validation
- Reward distribution
- Repeatable quest support

### Inventory System
- Item categorization and properties
- Equipment slots and stat bonuses
- Consumable items with effects
- Quantity management

## Technical Highlights

### Database Design
- Optimized indexes for common queries
- JSON columns for flexible data storage
- Foreign key constraints for data integrity
- Migration-based schema evolution

### Performance Optimizations
- Eager loading to prevent N+1 queries
- Database connection pooling
- Redis caching for sessions
- Background job processing

### Security Features
- CSRF protection
- SQL injection prevention
- Authorization policies
- Rate limiting middleware
- Content Security Policy

### Testing Strategy
- Model unit tests with edge cases
- Controller integration tests
- Service object isolation tests
- Feature tests with Capybara
- Factory-based test data

## Installation & Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/rails-quest.git
cd rails-quest

# Install dependencies
bundle install
yarn install

# Setup database
rails db:create
rails db:migrate
rails db:seed

# Start services
redis-server
bundle exec sidekiq

# Start the application
rails server