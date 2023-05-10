# frozen_string_literal: true

class SearchController < GeneralUsersController # :nodoc:
  # GET (/:locale)/search
  def index
    # Check rental type by RFS
    rentals = {'1' => :classic, '2' => :shared, '3' => :sleepin }
    posible_value_rentals= ['classic', 'shared', 'sleepin']
    if posible_value_rentals.index(helpers.type_rental)
       seacher = BoatSearcher.new(rentals[params[:rental_type]] || helpers.type_rental)
    else
       seacher = BoatSearcher.new(rentals[params[:rental_type]] || :classic)
    end
    # set @r_t with rental type to set radio checked
    case helpers.type_rental
    when "classic"
       @r_t=1
    when "shared"
       @r_t=2
    when "sleepin"
       @r_t=3
    else
      @r_t=1
   end

    @boats = seacher.where(params).paginate_and_order(params[:page], params[:per_page]).scope

    @page_title = t('search_bar.search')
    @location_short_name = ''
    # return unless location_set? || dates_set? || passengers_set?
    #
    # find_boats_by_filters
    set_min_max_prices
    # find_boats_classic_order_paginate
  end

  private

  def set_min_max_prices
    @per_half_day_minimum = @boats.classic.minimum(:per_half_day)
    @per_half_day_maximum = @boats.classic.maximum(:per_half_day)
    @sleepin_per_night_minimum = @boats.sleepin.minimum(:sleepin_per_night)
    @sleepin_per_night_maximum = @boats.sleepin.maximum(:sleepin_per_night)
    @shared_price_minimum = @boats.shared.minimum(:shared_price)
    @shared_price_maximum = @boats.shared.maximum(:shared_price)
  end

  def location_set?
    helpers.location[:lat] && helpers.location[:lng]
  end

  def dates_set?
    helpers.check_in_date && helpers.check_out_date
  end

  def passengers_set?
    helpers.passengers_count
  end

  def find_boats_by_filters
    @boats = Boat.enabled
                 .finished
                 .within_25_km(helpers.location[:lat], helpers.location[:lng])
                 .not_blocked_dates(helpers.check_in_date,
                                    helpers.check_out_date)
                 .can_book_now(helpers.type_rental,
                               helpers.check_in_date,
                               helpers.check_out_date)
                 .passengers_count(helpers.passengers_count)

  end

  def find_boats_classic_order_paginate
    @boats = @boats.classic
                   .by_date_desc
                   .page(1)
                   .per(12)
  end
end
