# frozen_string_literal: true

namespace :locations do
  desc 'Process and fill `locations`.`short_name` by Google Geocoding API'
  task fill_short_name: :environment do
    def update_short_name(location, type, google_geocoder_location)
      return unless google_geocoder_location.success

      city = if google_geocoder_location.city.present?
               google_geocoder_location.city
             else
               google_geocoder_location.district
             end

      short_name = [city, google_geocoder_location.country]
                   .reject(&:blank?).join(', ')

      puts "   -> Location by #{type}: id=#{location.id}, `#{short_name}`"
      location.update(short_name: short_name) if short_name.present?
    end

    puts '== Process and fill `locations`.`short_name` =='
    Location.find_each do |location|
      begin
        if location.lat.present? && location.lng.present?
          google_geocoder_location =
            Geokit::Geocoders::GoogleGeocoder.reverse_geocode(
              "#{location.lat},#{location.lng}"
            )
          update_short_name(location, 'coordinates', google_geocoder_location)
        elsif location.name.present?
          google_geocoder_location =
            Geokit::Geocoders::GoogleGeocoder.geocode(location.name)
          update_short_name(location, 'name', google_geocoder_location)
        end
      rescue TooManyQueriesError, GeocodeError, AccessDeniedError => error
        puts "Failed to process location #{location.id}"
        puts error.message
      end
    end
    puts '== `locations`.`short_name` processed and filled in DB =='
  end

  desc 'Process and fill `locations`.`lat` and `locations`.`lng` by Google Geocoding API'
  task fill_lat_lng_from_short_name: :environment do
    puts '== Process and fill `locations`.`lat` and `locations`.`lng` by Google Geocoding API =='
    Location.find_each do |location|
      next if location.lat.present? && location.lng.present?
      next unless location.name.present?
      begin
        google_geocoder_location = Geokit::Geocoders::GoogleGeocoder.geocode(location.name)
        if google_geocoder_location.lat.present? && google_geocoder_location.lng.present?
          location.update(
            lat: google_geocoder_location.lat,
            lng: google_geocoder_location.lng
          )
        end
      rescue TooManyQueriesError, GeocodeError, AccessDeniedError => error
        puts "Failed to process location #{location.id}"
        puts error.message
      end
    end
    puts '== `locations`.`lat` and `locations`.`lng` processed and filled in DB =='
  end

end
