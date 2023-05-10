# frozen_string_literal: true

module Users
  class WishlistController < GeneralUsersController # :nodoc:
    before_action :authenticate_user!

    def index
      @wishes = current_user.wishes
      similar_boats_ids = []
      @wishes.each do |wish|
        similar_boats_ids << Boat.within_10_km(wish.location.lat,
                                               wish.location.lng)
                                 .boat_type(wish.boat_type)
                                 .passengers_count(wish.passengers_count)
                                 .size_within_20_percent(wish.length)
                                 .pluck(:id)
      end
      @similar_boats = Boat.where(id: similar_boats_ids.flatten.uniq)
                           .where.not(id: @wishes.ids)
                           .by_date_desc
                           .limit(8)
    end
  end
end
