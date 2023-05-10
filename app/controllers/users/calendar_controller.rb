# frozen_string_literal: true

module Users
  class CalendarController < GeneralUsersController # :nodoc:
    before_action :authenticate_user!

    def index
      @finished_boats = current_user.boats.finished
    end
  end
end
