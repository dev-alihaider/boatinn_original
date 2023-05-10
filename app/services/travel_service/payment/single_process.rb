module TravelService::Payment
  class SingleProcess < BaseProcess

    # build one prime payment
    def build_payments
      [initiate_payment]
    end

  end
end
