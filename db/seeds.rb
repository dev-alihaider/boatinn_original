# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

categories_features = { 'Outdoor equipment': { category_type: 0, features: ['Bimini', 'Weel steering', 'Bow sundeck',
                                                                            'Deck shower', 'Bathing ladder',
                                                                            'Dining table', 'Outside fridge', 'BBQ', 'Fridge', 'Dinghy'] },
                        'Navigation equipment': { category_type: 0, features: ['Autopilot', 'Chart plotter',
                                                                               'Depth sounder', 'VHF', 'Fuel type gas',
                                                                               'Fuel type diesel'] },
                        'Digital equipment': { category_type: 0, features: ['Inverter', 'Mp3/CD player', 'WiFi'] },
                        'Sanitary facilities': { category_type: 0, features: ['Cold water', 'Hot water', 'Bathroom', 'Air conditioning'] },
                        'Kitchen equipment': { category_type: 0, features: %w[Sink Freezer Oven Fridge] },
                        'Experiences': { category_type: 1, features: ['Snorkel', 'Paddle surf', 'Kayak', 'Wake board',
                                                                      'Water sky', 'Boat delivery',
                                                                      'Discover sailing class', 'Advance sailing class', 'Party boat',
                                                                      'Sunrise experience', 'Scuba diving', 'Parasailing', 'Catacean watching',
                                                                      'Paddle yoga', 'Meditation', 'Long haul charter', 'Tours', 'Surf charter',
                                                                      'Sunset experience', 'Sunset dinner', 'Sunrise breakfast', 'Fishing charter',
                                                                      'Flyboarding'] } }

faq_attributes = [{ category: Faq.categories[:general],
                    title: 'Non-Discrimination Policy' },
                  { category: Faq.categories[:general],
                    title: 'Do I need insurance to rent a boat?' },
                  { category: Faq.categories[:general],
                    title: 'What is BoatINN?' },
                  { category: Faq.categories[:general],
                    title: 'How does BoatINN work?' },
                  { category: Faq.categories[:general],
                    title: 'Is there a cost to using BoatINN?' },
                  { category: Faq.categories[:general],
                    title: 'How can I create an account?' },
                  { category: Faq.categories[:general],
                    title: 'What are the BoatINN service fees?' },
                  { category: Faq.categories[:general],
                    title: 'What is the incidental coverage limit?' },
                  { category: Faq.categories[:general],
                    title: 'How does BoatINN handle cancellations and refunds' },
                  { category: Faq.categories[:for_renters],
                    title: 'Is your website secure?' },
                  { category: Faq.categories[:for_renters],
                    title: 'How do I reset my password?' },
                  { category: Faq.categories[:for_owners],
                    title: 'How do I enable text notifications?' }]

I18n.locale = :en
if HomepageSetting.count.zero?
  HomepageSetting.create!(
    community_for_sharing_title: 'There is a perfect charter for everyone',
    community_for_sharing_color: '#3AB6AE',
    community_for_sharing_descr: 'THE COMMUNITY FOR SHARING OR RENTING BOATS AND LIVING EXPERIENCES WITH LOCALS AROUND THE WORLD',
    community_for_sharing_title_image_1: 'Find your boat',
    community_for_sharing_descr_image_1: 'Rent the entire boat or find a sharing rental whether you rather to partials the costs and experiences',
    community_for_sharing_title_image_2: 'Meet people',
    community_for_sharing_descr_image_2: 'Many people has become lifetime friends while sharing cultures, languages and adventure',
    community_for_sharing_title_image_3: 'Safe money',
    community_for_sharing_descr_image_3: 'Make the most of your money sharing the rental costs. A sea experience has never been so affordable',
    # add listing section
    add_listing_section_title:           'Add a listing completely FREE in boatINN',
    add_listing_section_descr:           'It’s just takes a few minutes',
    add_listing_section_strip_color:     '#3AB6AE',
    add_listing_section_title_image_1:  'Be your own boss',
    add_listing_section_title_descr_1:  'With a free listing you can rent your boat. The boatINN plattform give you the support you need. We believe that the more people a product benefits the better the product is.',
    add_listing_section_title_image_2:  'Charter options',
    add_listing_section_title_descr_2:  'Rent your boat with or without captain. The classic charter and the sharing option will increase your reservations.',
    add_listing_section_title_image_3:  'Safe and easy',
    add_listing_section_title_descr_3:  'The boatINN platform provides you with an easy way to accept reservations and online payments.',
    add_listing_section_title_image_4:  'Insurance',
    add_listing_section_title_descr_4:  'Tenemos que averiguar que tipo de seguro necesitamos para un marketplace.',
    marketplace_slogan: 'There is a perfect charter for everyone'
  )
end

# categories_features
if Category.count.zero?
  categories_features.each do |category_name, features|
    category = Category.create!(name: category_name, category_type: features[:category_type])
    features[:features].each { |feature| category.features.create!(name: feature) }
  end
end

Faq.create!(faq_attributes) if Faq.count.zero?

I18n.locale = :en
if PrewizardSetting.count.zero?
  PrewizardSetting.create!(
    rent_your_boat_title_main: 'How boatINN works',
    rent_your_boat_strip_color: '#3AB6AE',
    rent_your_boat_title_1: 'Boat shared',
    rent_your_boat_descr_1: 'This option allows people to partials the costs of the rental. Attracting more customers to see experiences thanks fort he affordable prices. You fix a minimun number of passengers, whenever the boat is full you make more incomes. Try it.',
    rent_your_boat_title_2: 'SleepINN',
    rent_your_boat_descr_2: '90% of boats are used less than 21 days a year. Many customers might be interested renting your boat as accomodation. This way you make some extra money to cover your boat expences while at mooring.',
    rent_your_boat_title_3: 'Classic charter',
    rent_your_boat_descr_3: 'Rent your boat with or without captain, by day or week, to families, friends, parties, you choose.',
    rent_your_boat_title_4: 'Experiences',
    rent_your_boat_descr_4: 'Get more chances to generate reservations by offering different activities that you enjoy or are good at and you are willing to partials.',
    # explain_settings
    explain_settings_title_1: 'How do you charter a boat',
    explain_settings_strip_color_1: '#3AB6AE',
    explain_settings_descr_1: 'It\’s free and easy to create a listing on boatINN. Describe your space how many sailors can you accommodate, and add photos and details. You can also rent your boat with captain or without.',
    explain_settings_title_2: 'Welcome your sailors',
    explain_settings_strip_color_2: '#3AB6AE',
    explain_settings_descr_2: 'Get to know your guests before they arrive by messaging them on our platform. Most captains provide essencials. Some others even offer some welcome appetizers.',
    explain_settings_title_3: 'How you get paid',
    explain_settings_strip_color_3: '#3AB6AE',
    explain_settings_descr_3: 'BoatINN handles payment procedures, you don’t have to worry about it. Guests pay before they arrive. You are only charged a 3% of your confirm reservations to help us maintain the platform and give you support.',
    # safety_settings
    safety_settings_title_main: 'we care about your safety',
    safety_settings_title_1: 'Classic charter',
    safety_settings_descr_1: 'In the event of accidental damage, the property of every boatINN host is covered. It’s peace of mind at no extra charge',
    safety_settings_title_2: 'Host protection insurance',
    safety_settings_descr_2: 'If your guests get heart or cost property damages, our host protection insurance protects you for liability claims. It’s included free for every boatINN host',
    safety_settings_title_3: 'boatINN is built on trust',
    safety_settings_descr_3: 'All BoatINN travellers must submit a profile photo and verify their phone and email. Guest and host each publish reviews after check out keeping everyone  accountable and respectful'
  )
end
