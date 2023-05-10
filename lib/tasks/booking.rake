# frozen_string_literal: true

namespace :booking do
  desc 'Destroy all transactions, conversations, penalization, (for development)'
  task destroy_all: :environment do |_t, _args|
    [
      Travel::Trip,
      Travel::Booking,
      Travel::Payment,
      Travel::Customer,
      Travel::Invoice,
      Travel::Message,
      Travel::TripCancellation,
      Penalization,
      Review
    ].each do |model|
      sql = "TRUNCATE #{model.table_name} RESTART IDENTITY"
      ActiveRecord::Base.connection.execute(sql)
    end

    Boat.update_all(rating_hash: Reviews.rating_blank_for_boat)
  end

  desc 'reset review'
  task reset_review: :environment do |_t, _args|
    Boat.find_each do |boat|
      boat.update(rating_hash: Reviews.get_rating_for_boat(boat))
    end

    Review.find_each do |review|
      review.update(updated_at: Time.zone.now)
    end
  end



end
