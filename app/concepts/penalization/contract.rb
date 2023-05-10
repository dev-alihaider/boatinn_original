module Penalization::Contract

  class Create < Reform::Form
    property :user
    property :period_started_at
    property :period_end_at
    property :current_penalty_cents
    property :currency
    property :current_cancellations

    validates :user, presence: true
    validates :currency, presence: true
  end
end
