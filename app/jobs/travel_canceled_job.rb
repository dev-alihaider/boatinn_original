class TravelCanceledJob < ApplicationJob
  queue_as :default

  def perform(trip_id); end
end
