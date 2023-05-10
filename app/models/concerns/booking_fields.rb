module BookingFields
  extend ActiveSupport::Concern

  included do
    enum cancellation: { flexible: 0, moderate: 1, strict: 2 }
  end

end