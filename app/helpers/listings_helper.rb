# frozen_string_literal: true

module ListingsHelper # :nodoc:
  WIZARD_TOTAL_STEPS = 20
  WIZARD_NON_LISTING_STEPS = 4
  WIZARD_LISTING_STEPS = WIZARD_TOTAL_STEPS - WIZARD_NON_LISTING_STEPS
  PRECISION = 0

  def boat_image_url(boat, style = nil)
    image_url(boat.images&.order(:priority)&.first&.attachment&.url(style) ||
              Asset.new.attachment.url(style))
  end

  def listing_params_url(boat, url_params = {})
    url_helper_params = { locale: current_locale  }

    if url_params[:rental_type].present? && url_params[:rental_type] != :classic
      url_helper_params[:rental_type] = url_params[:rental_type]
    end
    url_helper_params[:check_in_date]    = url_params[:check_in_date].presence
    url_helper_params[:check_out_date]   = url_params[:check_out_date].presence
    url_helper_params[:passengers_count] = url_params[:passengers_count].presence
    # need set host
    # listing_url(boat, url_helper_params)
    listing_path(boat, url_helper_params)
  end

  def boat_last_update(updated)
    "#{t('dashboard.listings.index.last_update')}: #{updated.strftime('%d/%m/%Y')}"
  end

  def switcher_status(status)
    if status
      t('dashboard.listings.index.online')
    else
      t('dashboard.listings.index.offline')
    end
  end

  def switcher_sleepin_label(status)
    if status
      t('dashboard.listings.index.sleepin_active')
    else
      t('dashboard.listings.index.activate_sleepin')
    end
  end

  def switcher_shared_label(status)
    if status
      t('dashboard.listings.index.boat_shared_active')
    else
      t('dashboard.listings.index.activate_boat_shared')
    end
  end

  # Stage 8  - 1st non-listing page (finish first stage screen)
  # Stage 9  - 2nd non-listing page (Facebook image import/file uploading)
  # Stage 10 - 3rd non-listing page (phone number verification)
  # Stage 13 - 4th non-listing page (finish second stage screen)
  def wizard_readiness_percentage(boat)
    wizard_readiness = case boat.wizard_progress.to_i
                       when 0..7 then boat.wizard_progress.to_i
                       when 8 then boat.wizard_progress - 1
                       when 9 then boat.wizard_progress - 2
                       when 10..12 then boat.wizard_progress - 3
                       when 13..19 then boat.wizard_progress - 4
                       else WIZARD_LISTING_STEPS
                       end

    (wizard_readiness * 100.0 / WIZARD_LISTING_STEPS).round
  end

  def current_user_listings(listings, path_helper = :edit)
    listings.map do |listing|
      path = case path_helper
             when :edit then edit_dashboard_listing_path(listing.id)
             when :settings then settings_dashboard_listing_path(listing.id)
             when :calendar
               api_boat_booking_blockings_path(listing.id, locale: nil)
             when :statistics_ratings
               ratings_dashboard_statistics_path(boat_id: listing.id)
             when :statistics_views
               views_dashboard_statistics_path(boat_id: listing.id)
             else listing_path(listing.id)
             end
      [listing.listing_title, listing.id, { data: { path: path } }]
    end
  end

  # Convert stored in DB value to human readable value by comparing value with
  # options array: [['1/2 day', 0.5.days.to_i],...]. Returns '' if not found.
  def to_human(options, value)
    options.map { |option| return option.first if option.last.to_s == value.to_s }
    ''
  end

  # Used in `app/views/users/listings/settings.html.slim`
  def ajax_data_attrs(listing, payload)
    { url: api_boat_path(listing, locale: nil), payload: payload }
  end

  def with_captain_options
    [[t('wizards.index.page05.with_captain'), :with],
     [t('wizards.index.page05.without_captain'), :without],
     [t('wizards.index.page05.with_or_without_captain'), :with_or_without]]
  end

  def edit_header_link(boat, stage = nil, link = nil)
    if stage.present?
      edit_wizard_path(boat, stage: stage)
    elsif link.present?
      link
    else
      'javascript:void(0)'
    end
  end

  def price_type_options(boat)
    price_type_options_classic(boat, price_type_options = [])
    price_type_options_shared(boat, price_type_options)
    price_type_options_sleepin(boat, price_type_options)
    price_type_options
  end

  # For details about `@price_type_selected_option` value see
  # `ListingsHelper#price_type_options`, `#price_type_options_classic`,
  # `#price_type_options_shared`, `#price_type_options_sleepin`.
  def price_type_selected_option
    @price_type_selected_option ||= case rental_type
                                    when :sleepin then 6
                                    when :shared then 5
                                    else 1 # :classic
                                    end
  end

  def rental_type
    @rental_type ||= begin
      boat_rental_types = []

      # Note: here is set the order of boat info tabs selection on listing page
      boat_rental_types << 'classic' if @boat.classic?
      boat_rental_types << 'shared'  if @boat.shared?
      boat_rental_types << 'sleepin' if @boat.sleepin?

      if boat_rental_types.include?(params[:rental_type])
        params[:rental_type].to_sym
      else
        boat_rental_types&.first&.to_sym
      end
    end
  end

  def max_passengers_count(boat)
    @max_passengers_count ||= case rental_type
                              when :sleepin then boat.sleepin_max_passengers
                              when :shared then boat.shared_max_passengers
                              else boat.passengers_count # :classic
                              end
  end

  def min_price(boat)
    return @min_price if @min_price

    prices = []
    if boat.classic?
      prices = [boat.per_half_day.to_f, boat.per_day.to_f,
                boat.per_night.to_f, boat.per_week.to_f]
    end
    prices << boat.sleepin_per_night.to_f if boat.sleepin?
    prices << boat.shared_price.to_f if boat.shared?
    @min_price = prices.min
  end

  def instant_booking_button_data_attrs(boat)
    { classic: boat.classic?,
      sleepin: boat.sleepin?,
      shared: boat.shared?,
      instant_booking_classic: boat.instant_booking_classic?,
      instant_booking_sleepin: boat.instant_booking_sleepin?,
      instant_booking_shared: boat.instant_booking_shared?,
      instant_booking_enabled_text:
        t('users.listings.show.booking_calculator.instant_book'),
      instant_booking_disabled_text:
        t('users.listings.show.booking_calculator.request_a_book'),
      path: new_booking_path,
      method: 'get'
    }
  end

  def booking_button_text(boat)
    instant_booking_texts = [
      t('users.listings.show.booking_calculator.request_a_book'),
      t('users.listings.show.booking_calculator.instant_book')
    ]
    instant_booking_enabled = case rental_type
                              when :sleepin then boat.instant_booking_sleepin?
                              when :shared then boat.instant_booking_shared?
                              else boat.instant_booking_classic? # :classic
                              end
    instant_booking_texts[instant_booking_enabled && 1 || 0]
  end

  def price_or_nil(price)
    if price.to_f.zero?
      nil
    else
      number_with_precision(price, precision: ListingsHelper::PRECISION,
                                   strip_insignificant_zeros: true)
    end
  end

  def avg_boat_rating(boat)
    rating = boat.rating_hash.dup
    rating.delete(:count)
    rating = rating.values
    rating.sum.to_f / rating.size.to_f
  end

  def avg_rating_review(review)
    rating = [
      review.communication_grade,
      review.cleanliness_grade,
      review.boat_rules_grade,
      review.accuracy_grade,
      review.location_grade,
      review.check_in_grade,
      review.value_grade,
    ].compact
    rating.sum.to_f / rating.size.to_f
  end

  def captain_level_professional?(user)
    user.settings(:your_cv)&.your_level == 'pro'
  end

  def display_response_time(seconds)
    hours = (seconds.to_f / 60.0 / 60.0).to_i

    interval_translation = case hours
                           when 0..1 then 'within_an_hour'
                           when 2 then 'within_two_hours'
                           when 3 then 'within_three_hours'
                           when 3..12 then 'within_half_day'
                           when 12..24 then 'within_day'
                           when 24..48 then 'within_two_days'
                           when 48..72 then 'within_three_days'
                           else 'more_than_three_days'
                           end

    I18n.t("responses.#{interval_translation}")
  end

  private

  def price_type_options_classic(boat, price_type_options)
    return unless boat.classic?

    price_type_options.push(
      [t('users.listings.show.booking_calculator.price_type.half_day_short'),
       { data: {
         price_unit:
           t('users.listings.show.booking_calculator.sum_caption.half_day'),
         price: boat.per_half_day
       } }, 1],
      [t('users.listings.show.booking_calculator.price_type.full_day_short'),
       { data: {
         price_unit:
           t('users.listings.show.booking_calculator.sum_caption.full_day'),
         price: boat.per_day
       } }, 2],
      [t('users.listings.show.booking_calculator.price_type.per_night'),
       { data: {
         price_unit:
           t('users.listings.show.booking_calculator.sum_caption.night'),
         price: boat.per_night
       } }, 3],
      [t('users.listings.show.booking_calculator.price_type.per_week'),
       { data: {
         price_unit:
           t('users.listings.show.booking_calculator.sum_caption.week'),
         price: boat.per_week
       } }, 4]
    )
  end

  def price_type_options_sleepin(boat, price_type_options)
    return unless boat.sleepin?

    price_type_options <<
      [t('users.listings.show.booking_calculator.price_type.sleepinn'),
       { data: {
         price_unit:
           t('users.listings.show.booking_calculator.sum_caption.sleepin'),
         price: boat.sleepin_per_night
       } }, 6]
  end

  def price_type_options_shared(boat, price_type_options)
    return unless boat.shared?

    price_type_options <<
      [t('users.listings.show.booking_calculator.price_type.boat_shared'),
       { data: {
         price_unit:
           t('users.listings.show.booking_calculator.sum_caption.shared'),
         price: boat.shared_price
       } }, 5]
  end

  def boat_length(length_in_meters)
    "#{length_in_meters} mt / #{(length_in_meters / Boat::ONE_FEET_IN_METERS).round} ft"
  end

  def builders_array
    [
      "Aegean Yacht",
      "Alexander Stephen and Sons",
      "Alloy Yachts",
      "Aloha Yachts",
      "Alsberg Brothers Boatworks",
      "Amel Yachts",
      "Austral Yachts",
      "Baltic Yachts",
      "Bavaria",
      "Beneteau",
      "Bowman Yachts",
      "Bristol Yachts",
      "C&C Yachts",
      "Cabo Rico Yachts",
      "Cal Yachts",
      "Calgan Marine",
      "Camper and Nicholsons",
      "Cape Dory Yachts",
      "Caribbean Sailing Yachts",
      "Cascade Yachts",
      "Catalina Yachts",
      "Cavalier Yachts",
      "Clark Boat Company",
      "Columbia Yachts",
      "Coronado Yachts",
      "CS Yachts",
      "CW Hood Yachts",
      "Dehler Yachts",
      "Down East Yachts",
      "Dragonfly Trimarans",
      "Dufour Yachts",
      "Ericson Yachts",
      "Freedom Yachts",
      "George Lawley & Son",
      "Grampian Marine",
      "Hallberg-Rassy",
      "Hans Christian Yachts",
      "Hanse Yachts",
      "Hinckley Yachts",
      "Hodgdon Brothers",
      "Hodgdon Yachts",
      "Holland Jachtbouw",
      "Hunter Boats",
      "Hunter Marine",
      "Hylas Yachts",
      "Island Packet Yachts",
      "J. Samuel White",
      "Jakobson Shipyard",
      "Jeanneau",
      "Jensen Marine",
      "Jeremy Rogers Limited",
      "Johnson Boat Works",
      "Jongert",
      "Laser Performance",
      "Little Harbor",
      "MacGregor Yacht Corporation",
      "Marlow-Hunter Marine",
      "Melges Performance Sailboats",
      "Mirage Yachts",
      "Najad Yachts",
      "Nauticat Yachts Oy",
      "Nautor's Swan",
      "O'Day Corp.",
      "Ontario Yachts",
      "Oyster Marine",
      "Pacific Seacraft",
      "Palmer Johnson",
      "Pearson Yachts",
      "Perini Navi",
      "Royal Denship",
      "Royal Huisman",
      "Rustler Yachts",
      "S2 Yachts",
      "Smith and Rhuland",
      "Su Marine Yachts",
      "Tanzer Industries",
      "Tartan Marine",
      "Vanguard Sailboats",
      "Varne Marine",
      "W. D. Schock Corporation",
      "Wally Yachts",
      "X-Yachts",
      "A.F. Theriault & Sons Shipyard",
      "Alumaweld Boats",
      "Amel Yachts",
      "American Skier",
      "Andrée & Rosenqvist",
      "Bayliner",
      "Beneteau",
      "Benetti",
      "Blohm + Voss",
      "Boston Whaler",
      "Brunswick Boat Group",
      "Burger Boat Company",
      "Cantieri di Pisa",
      "Carter Marine",
      "Carver Yachts",
      "Centurion Boats",
      "Chaparral Boats",
      "Chris-Craft Boats",
      "Cimmarron Boats",
      "Clyde Boats",
      "Cobalt Boats",
      "Codecasa",
      "Correct Craft",
      "Cruisers Yachts",
      "Duckworth Boats",
      "Eaglecraft",
      "Evinrude",
      "Feadship",
      "Ferretti Group",
      "Front Street Shipyard",
      "Front Street Shipyard",
      "Glastron",
      "Gulf Craft",
      "Gulf Craft",
      "HanseYachts",
      "Herbert Woods",
      "Horizon Yacht",
      "ICON Yachts",
      "Jade Yachts",
      "Jeanneau",
      "Kadey-Krogen Yachts",
      "KingFisher Boats",
      "Lazzara",
      "Lowe Boats",
      "Lürssen",
      "Malibu Boats",
      "MasterCraft",
      "Maxum",
      "Mondomarine",
      "Nobiskrug",
      "Northwest Boats",
      "Ocean Alexander",
      "oceAnco",
      "Pavati",
      "Pearson Yachts",
      "Porta-bote",
      "Princess",
      "Renaissance Marine Group",
      "Royal Yacht",
      "Sea Ray",
      "Ski Nautique",
      "StanCraft Boat Company",
      "Starcraft Marine",
      "Su Marine Yachts",
      "Sunseeker",
      "Sunseeker",
      "Ta shing (yacht)",
      "Tayana Yachts",
      "Tiara Yachts",
      "Tollycraft",
      "Trojan Yachts",
      "Uniflite",
      "Wacanda Marine",
      "Wally Yachts",
      "Weldcraft",
      "Yamaha Motor Corporation",
      "Armstrong Marine",
      "Farrier Marine",
      "Front Street Shipyard",
      "KaiserWerft",
      "Bombardier",
      "Bossoms Boatyard",
      "Boston Whaler",
      "Corsair Marine",
      "Honda Marine Group",
      "Kawasaki Heavy Industries",
      "Yamaha Motor Corporation",
      "Z1 Boats",
      "Zodiac Group"
    ]
  end
end
