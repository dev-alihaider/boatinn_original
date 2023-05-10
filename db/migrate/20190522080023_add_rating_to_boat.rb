class AddRatingToBoat < ActiveRecord::Migration[5.1]
  def up
    add_column :boats, :rating_hash, :text, default: Reviews.rating_blank_for_boat.to_yaml

    # initiate jobs for pending reviews
    Travel::Trip.find_each do |trip|
      Travel::TripFinishedJob.set(wait_until: trip.check_out).perform_later(trip.id)
    end
  end

  def down
    remove_column :boats, :rating_hash
  end
end
