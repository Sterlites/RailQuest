# db/seeds.rb
# Comprehensive seed data for development and testing
puts "🌱 Seeding Rails Quest database..."

# Clear existing data in development
if Rails.env.development?
  puts "Clearing existing data..."
  [CombatLog, UserQuest, UserItem, GameSession, User, Quest, Item, Location].each(&:delete_all)
end

# Create Locations
puts "Creating locations..."

locations_data = [
  {
    name: 'Town Square',
    description: 'The bustling center of town with merchants and travelers.',
    long_description: 'A large cobblestone square surrounded by shops, taverns, and guild halls. The fountain in the center provides fresh water, and town guards patrol regularly, making this a safe haven for adventurers.',
    exits: { 'north' => 2, 'east' => 3, 'west' => 4 },
    items: {},
    npcs: { 'merchant' => 'A friendly merchant', 'guard' => 'A town guard' },
    safe_zone: true,
    required_level: 1
  },
  {
    name: 'Dark Forest',
    description: 'A mysterious forest filled with shadows and strange sounds.',
    long_description: 'Ancient trees tower overhead, their branches blocking most sunlight. Strange sounds echo from deeper in the forest, and you can see glowing eyes watching from the shadows.',
    exits: { 'south' => 1, 'north' => 5, 'east' => 6 },
    items: {},
    npcs: {},
    safe_zone: false,
    required_level: 3
  },
  {
    name: 'Old Ruins',
    description: 'Crumbling stone structures from a forgotten civilization.',
    long_description: 'Moss-covered stones and broken pillars are all that remain of what must have been a grand structure. Ancient runes are carved into some stones, though their meaning is lost to time.',
    exits: { 'west' => 1, 'north' => 7 },
    items: {},
    npcs: {},
    safe_zone: false,
    required_level: 2
  },
  {
    name: 'Merchant District',
    description: 'A busy area filled with shops and trading posts.',
    long_description: 'Colorful banners hang from shop fronts, and the air is filled with the sounds of haggling and commerce. Various goods from across the realm can be found here.',
    exits: { 'east' => 1 },
    items: {},
    npcs: { 'shopkeeper' => 'A busy shopkeeper', 'trader' => 'A traveling trader' },
    safe_zone: true,
    required_level: 1
  },
  {
    name: 'Mountain Path',
    description: 'A treacherous path winding up the mountainside.',
    long_description: 'Rocky outcroppings and loose stones make this path dangerous to traverse. The air grows thinner as the path climbs higher, and mountain creatures can be heard in the distance.',
    exits: { 'south' => 2, 'up' => 8 },
    items: {},
    npcs: {},
    safe_zone: false,
    required_level: 5
  },
  {
    name: 'Goblin Camp',
    description: 'A crude camp filled with hostile goblins.',
    long_description: 'Rough wooden structures and smoldering fire pits mark this as goblin territory. The smell is terrible, and you can hear guttural voices arguing in the goblin tongue.',
    exits: { 'west' => 2 },
    items: {},
    npcs: { 'goblin_chief' => 'A large, menacing goblin chief' },
    safe_zone: false,
    required_level: 4
  },
  {
    name: 'Ancient Temple',
    description: 'A mysterious temple with strange magical energies.',
    long_description: 'Intricate carvings cover every surface of this ancient temple. A faint magical glow emanates from within, and the air hums with power.',
    exits: { 'south' => 3 },
    items: {},
    npcs: { 'temple_guardian' => 'An ethereal temple guardian' },
    safe_zone: false,
    required_level: 6
  },
  {
    name: 'Mountain Peak',
    description: 'The highest point of the mountain, with breathtaking views.',
    long_description: 'From this vantage point, you can see for miles in every direction. The air is thin and cold, but the view is magnificent. An ancient shrine sits at the very peak.',
    exits: { 'down' => 5 },
    items: {},
    npcs: { 'hermit' => 'A wise mountain hermit' },
    safe_zone: true,
    required_level: 8
  }
]

locations = {}
locations_data.each do |location_data|
  location = Location.create!(location_data)
  locations[location_data[:name]] = location
  puts "  ✓ Created #{location.name}"
end

# Create Items
puts "Creating items..."

items_data = [
  # Weapons
  {
    name: 'Wooden Sword',
    description: 'A basic training sword made of wood.',
    item_type: 'weapon',
    value: 10,
    properties: { 'attack' => 5, 'required_level' => 1 },
    equippable: true,
    equipment_slot: 'weapon'
  },
  {
    name: 'Iron Sword',
    description: 'A sturdy iron sword with a sharp edge.',
    item_type: 'weapon',
    value: 50,
    properties: { 'attack' => 12, 'required_level' => 5 },
    equippable: true,
    equipment_slot: 'weapon'
  },
  {
    name: 'Steel Sword',
    description: 'A finely crafted steel sword.',
    item_type: 'weapon',
    value: 150,
    properties: { 'attack' => 20, 'required_level' => 10 },
    equippable: true,
    equipment_slot: 'weapon'
  },
  
  # Armor
  {
    name: 'Leather Armor',
    description: 'Basic leather armor providing minimal protection.',
    item_type: 'armor',
    value: 25,
    properties: { 'defense' => 3, 'required_level' => 1 },
    equippable: true,
    equipment_slot: 'chest'
  },
  {
    name: 'Chain Mail',
    description: 'Interlocked metal rings providing good protection.',
    item_type: 'armor',
    value: 75,
    properties: { 'defense' => 8, 'required_level' => 5 },
    equippable: true,
    equipment_slot: 'chest'
  },
  {
    name: 'Plate Armor',
    description: 'Heavy metal plates offering excellent protection.',
    item_type: 'armor',
    value: 200,
    properties: { 'defense' => 15, 'required_level' => 10 },
    equippable: true,
    equipment_slot: 'chest'
  },
  
  # Consumables
  {
    name: 'Health Potion',
    description: 'A red potion that restores health when consumed.',
    item_type: 'consumable',
    value: 20,
    properties: { 'healing' => 30, 'effect' => 'heal' },
    consumable: true
  },
  {
    name: 'Mana Potion', 
    description: 'A blue potion that restores mana when consumed.',
    item_type: 'consumable',
    value: 25,
    properties: { 'mana' => 20, 'effect' => 'mana' },
    consumable: true
  },
  {
    name: 'Experience Crystal',
    description: 'A glowing crystal that grants experience when used.',
    item_type: 'consumable',
    value: 100,
    properties: { 'experience' => 50, 'effect' => 'experience' },
    consumable: true
  },
  
  # Special Items
  {
    name: 'Town Portal Scroll',
    description: 'A magical scroll that teleports you back to town.',
    item_type: 'consumable',
    value: 50,
    properties: { 'special_effects' => ['teleport_to_town'], 'effect' => 'teleport' },
    consumable: true
  },
  {
    name: 'Magic Ring',
    description: 'A mysterious ring that enhances your abilities.',
    item_type: 'armor',
    value: 300,
    properties: { 'attack' => 5, 'defense' => 5, 'required_level' => 15 },
    equippable: true,
    equipment_slot: 'ring'
  }
]

items = {}
items_data.each do |item_data|
  item = Item.create!(item_data)
  items[item_data[:name]] = item
  puts "  ✓ Created #{item.name}"
end

# Add some items to locations
puts "Placing items in locations..."
locations['Town Square'].add_item(items['Health Potion'], 2)
locations['Town Square'].add_item(items['Wooden Sword'], 1)
locations['Dark Forest'].add_item(items['Mana Potion'], 1)
locations['Mountain Peak'].add_item(items['Experience Crystal'], 1)
locations['Ancient Temple'].add_item(items['Magic Ring'], 1)

# Create Quests
puts "Creating quests..."

quests_data = [
  {
    name: 'Welcome to Adventure',
    description: 'Learn the basics of adventuring by exploring the town and nearby areas.',
    objectives: {
      'visit_location_2' => 1,  # Visit Dark Forest
      'kill_enemy_goblin' => 3
    },
    rewards: {
      'experience' => 100,
      'gold' => 50,
      'items' => [
        { 'item_id' => items['Health Potion'].id, 'quantity' => 2 }
      ]
    },
    required_level: 1
  },
  {
    name: 'Clear the Goblin Camp', 
    description: 'The goblin camp threatens trade routes. Clear it out for the merchants.',
    objectives: {
      'visit_location_6' => 1,  # Visit Goblin Camp
      'kill_enemy_goblin' => 10,
      'kill_enemy_goblin_chief' => 1
    },
    rewards: {
      'experience' => 300,
      'gold' => 200,
      'items' => [
        { 'item_id' => items['Iron Sword'].id, 'quantity' => 1 }
      ]
    },
    required_level: 4
  },
  {
    name: 'Ancient Mysteries',
    description: 'Investigate the ancient temple and discover its secrets.',
    objectives: {
      'visit_location_7' => 1,  # Visit Ancient Temple
      'use_item_' + items['Experience Crystal'].id.to_s => 1
    },
    rewards: {
      'experience' => 500,
      'gold' => 300,
      'items' => [
        { 'item_id' => items['Steel Sword'].id, 'quantity' => 1 }
      ]
    },
    required_level: 6
  },
  {
    name: 'Mountain Pilgrimage',
    description: 'Reach the mountain peak and seek wisdom from the hermit.',
    objectives: {
      'visit_location_8' => 1   # Visit Mountain Peak
    },
    rewards: {
      'experience' => 200,
      'gold' => 100,
      'items' => [
        { 'item_id' => items['Town Portal Scroll'].id, 'quantity' => 3 }
      ]
    },
    required_level: 7
  }
]

quests_data.each do |quest_data|
  quest = Quest.create!(quest_data)
  puts "  ✓ Created quest: #{quest.name}"
end

# Create a demo user for testing
if Rails.env.development?
  puts "Creating demo user..."
  
  demo_user = User.create!(
    email: 'demo@railsquest.com',
    password: 'password123',
    username: 'DemoHero',
    level: 5,
    experience: 450,
    gold: 200,
    health: 80,
    max_health: 80,
    mana: 40,
    max_mana: 40
  )
  
  # Give demo user some starting items
  demo_user.user_items.create!(item: items['Wooden Sword'], quantity: 1, equipped: true)
  demo_user.user_items.create!(item: items['Leather Armor'], quantity: 1, equipped: true)
  demo_user.user_items.create!(item: items['Health Potion'], quantity: 5)
  demo_user.user_items.create!(item: items['Mana Potion'], quantity: 3)
  
  puts "  ✓ Created demo user: #{demo_user.username}"
  puts "    Email: demo@railsquest.com"
  puts "    Password: password123"
end

puts "🎉 Database seeded successfully!"
puts
puts "Rails Quest is ready to play!"
puts "Features demonstrated:"
puts "  ✓ MVC Architecture with complex models"
puts "  ✓ RESTful routing and controllers"
puts "  ✓ ActiveRecord associations and validations"
puts "  ✓ Background jobs with ActiveJob/Sidekiq"
puts "  ✓ Authorization with Pundit"
puts "  ✓ Service objects for business logic"
puts "  ✓ Modern JavaScript with Stimulus"
puts "  ✓ Comprehensive test coverage setup"
puts "  ✓ Production-ready patterns and practices"