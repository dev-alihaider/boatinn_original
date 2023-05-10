# frozen_string_literal: true

module ApplicationHelper # :nodoc:
  def current_locale
    current_user&.language.presence ||
      session[:locale] ||
      I18n.locale ||
      I18n.default_locale
  end

  PAYMENT_IMAGES = {
    'visa'              => 'payments/visa.png',
    'mastercard'        => 'payments/mastercard.png',
    'american express'  => 'payments/american_express.png',
    'jcb'               => 'payments/jcb.png',
    'discover'          => 'payments/discover.png',
    'unionpay'          => 'payments/unionpay.png',
    'diners club'       => 'payments/dinners_club.png'
  }.freeze

  PAYMENT_NAMES = {
    'visa'              => 'Visa',
    'mastercard'        => 'Master Card',
    'american express'  => 'American Express',
    'jcb'               => 'JCB',
    'discover'          => 'Discover',
    'unionpay'          => 'UnionPay',
    'diners club'       => 'Dinners Club'
  }.freeze

  def available_locales_options
    Boatinn::AVAILABLE_LOCALES.map do |l|
      [l[:name].upcase, l[:ident],
       { data: { url: change_local_path(l[:ident]) } }]
    end
  end

  def locale_name(locale_id)
    locale = Boatinn::AVAILABLE_LOCALES.find { |x| x[:ident] == locale_id }
    locale ? locale[:name] : ''
  end

  def default_check_in_out(check_in_out)
    Time.at(check_in_out).utc if check_in_out.present?
  end

  def check_in_out_times
    ar_times = []
    ('2000-01-01'.to_datetime.to_i..'2000-01-01'.to_datetime.end_of_day.to_i).step(30.minutes) do |date|
      ar_times << [Time.at(date).utc.strftime('%H:%M'), Time.at(date).utc]
    end
    ar_times.unshift(['', ''])
  end

  def boat_type_options
    [[''],
     [t('wizards.index.page01.boat_type.catamaran'), :catamaran],
     [t('wizards.index.page01.boat_type.power_boat'), :power_boat],
     [t('wizards.index.page01.boat_type.sailing_boat'), :sailing_boat],
     [t('wizards.index.page01.boat_type.jet_sky'), :jet_sky],
     [t('wizards.index.page01.boat_type.rib'), :rib],
     [t('wizards.index.page01.boat_type.pontoon'), :pontoon]]
  end

  def passengers_count_options
    [''] + 1.upto(50).map(&:to_s)
  end

  def min_passengers_count_options
    [''] + 1.upto(2).map(&:to_s)
  end

  def minimum_rental_times
    [[t('wizards.index.page15.min_stay_half_day'), 0.5.days.to_i],
     [t('wizards.index.page15.min_stay_1_day'), 1.day],
     [t('wizards.index.page15.min_stay_2_days'), 2.days],
     [t('wizards.index.page15.min_stay_3_days'), 3.days],
     [t('wizards.index.page15.min_stay_4_days'), 4.days],
     [t('wizards.index.page15.min_stay_5_days'), 5.days],
     [t('wizards.index.page15.min_stay_6_days'), 6.days],
     [t('wizards.index.page15.min_stay_1_week'), 1.week],
     [t('wizards.index.page15.min_stay_2_weeks'), 2.weeks],
     [t('wizards.index.page15.min_stay_3_weeks'), 3.weeks]]
  end

  # TODO: Add i18n.
  def minimum_rental_times_sleepin
    [['1 night', 1.day],
     ['2 nights', 2.days],
     ['3 nights', 3.days],
     ['4 nights', 4.days],
     ['5 nights', 5.days],
     ['6 nights', 6.days],
     ['1 week', 1.week],
     ['2 weeks', 2.weeks],
     ['3 weeks', 3.weeks]]
  end

  # TODO: @Andrew: Uncomment and fix error in `Users::RegistrationsController`, `Users::SessionsController`:
  # ActionController::UrlGenerationError at /users
  # No route matches {:action=>"index", :controller=>"users/homepages", :locale=>"en"}
  def change_local_path(local)
    current_url = request.env['PATH_INFO']
    path = Rails.application.routes.recognize_path(current_url)
    path[:locale] = local
    if params[:location].present?
      path[:location] = { name: params[:location][:name].presence,
                          lat: params[:location][:lat].presence,
                          lng: params[:location][:lng].presence }
    end
    path[:check_in_date] = params[:check_in_date].presence
    path[:check_out_date] = params[:check_out_date].presence
    path[:passengers_count] = params[:passengers_count].presence
    path[:type_rental] =  params[:type_rental].presence

    url_for path
  rescue StandardError
    ''
  end

  # Display model validation errors in form templates
  def display_validation_errors(object)
    return '' if object.errors.empty?

    header = I18n.t('activerecord.errors.template.header')
    msgs = object.errors.full_messages.map { |msg| content_tag(:li, msg) }.join

    html = <<-HTML
      <div class="alert alert-danger alert-dismissable" role="alert">
        <button type="button" class="close" data-dismiss="alert">
          <span aria-hidden="true">&times;</span><span class="sr-only">Close</span>
        </button>
        <h4>
          #{header}
        </h4>
        <ul>#{msgs}</ul>
      </div>
    HTML

    html.html_safe
  end

  def asset_exists?(asset)
    Rails.application.assets.find_asset asset
  end

  def custom_controller_name(controller_)
    controller_
  end

  def controller_css_name
    "controllers/#{custom_controller_name(controller_name)}.css"
  end

  def action_css_name
    "controllers/#{controller_name}/#{action_name}.css"
  end

  def controller_js_name
    "controllers/#{custom_controller_name(controller_name)}.js"
  end

  def project_logo
    logo_url = HomepageSettingImage.with_slug('hp_logo').first&.image&.attachment&.url # (:logo)
    logo_url.present? ? image_tag(logo_url, class: 'normal') : image_tag('', class: 'normal')
  end

  def custom_figure_field(field, figure)
    if figure.positive?
      "#{field}_#{figure}".to_sym
    else
      field.to_sym
    end
  end

  def rent_your_boat_field(entity, field, figure)
    entity.send(custom_figure_field(field, figure))
  end

  def rent_your_boat_icons(figure)
    %w[bt-icon-highfive bt-icon-sleeping bt-icon-boat2 bt-icon-mermaid][figure - 1]
  end

  def safety_icons(figure)
    %w[bt-icon-certificate bt-icon-document bt-icon-handshake][figure - 1]
  end

  def custom_hr(color)
    content_tag(:hr, style: "background:#{color} !important;") do
    end
  end

  def location
    @location ||= if params[:location].present?
                    if params[:location][:name].present? &&
                       (params[:location][:lat].blank? ||
                        params[:location][:lng].blank?)
                      location = Geokit::Geocoders::GoogleGeocoder.geocode(
                        params[:location][:name]
                      )
                      if location.success
                        params[:location][:lat] = location.lat
                        params[:location][:lng] = location.lng
                      end
                    end
                    { name: params[:location][:name].presence,
                      lat: params[:location][:lat].presence,
                      lng: params[:location][:lng].presence }
                  else
                    { name: nil, lat: nil, lng: nil }
                  end
  end

  def check_in_date
    @check_in_date ||= params[:check_in_date].presence
  end

  def check_out_date
    @check_out_date ||= params[:check_out_date].presence
  end

  def passengers_count
    @passengers_count ||= params[:passengers_count].presence
  end

  def type_rental
    @type_rental ||= params[:type_rental].presence
  end


  def payment_image(source)
    PAYMENT_IMAGES.each do |brand, image|
      return image if (source.to_s).start_with?(brand)
    end
    PAYMENT_IMAGES['visa']
  end

  def payment_name(source)
    return I18n.t('users.payments.card_not_present') if source.blank?

    PAYMENT_NAMES.each do |brand, name|
      return name if (source.to_s).start_with?(brand)
    end
    PAYMENT_NAMES['visa']
  end

  def credit_card_name(card)
    "#{payment_name(card.brand)} #{source_short_format(card.number)}"
  end

  def source_without_brand(source)
    source.to_s[-20, 20]
  end

  def source_short_format(source)
    source.to_s[-9, 9]
  end

  def collection_portion(collection, size)
    size = size.to_i
    return yield(collection) if size.zero? || collection.size.zero?

    group_size = (collection.size.to_f / size.to_f).ceil

    groups = []
    counter = 0

    group_size.times do |index|
      size.times do
        break if collection[counter].blank?
        groups[index] = [] if groups[index].blank?
        groups[index] << collection[counter]
        counter += 1
      end
    end

    groups.each do |sub_collection|
      yield(sub_collection)
    end

    nil
  end

  def current_user?(user)
    current_user == user
  end
  
  # RFS 10.05.2020 detect mobile device
  def mobile_device
    agent = request.user_agent
    return "tablet" if agent =~ /(tablet|ipad)|(android(?!.*mobile))/i
    return "mobile" if agent =~ /Mobile/
    return "desktop"
  end

end
