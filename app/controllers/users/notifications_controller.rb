# frozen_string_literal: true

module Users
  class NotificationsController < GeneralUsersController # :nodoc:
    before_action :authenticate_user!

  end
end
