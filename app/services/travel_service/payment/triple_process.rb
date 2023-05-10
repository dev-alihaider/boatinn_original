module TravelService::Payment
  class TripleProcess < DualProcess

    # build deposit payment for deffer pay 30%
    # build main payment for deferred pay 70%
    def build_payments(gw_fields = {})
      payments = super(gw_fields = {})

      payments.first.attributes = {
        plan_charge_at: first_pay_date,
        type_of: :deposit
      }

      payments.second.attributes = {
        plan_charge_at: second_pay_date,
        type_of: :prime
      }

      payments
    end

    def first_pay_date
      days = (TravelService::Preference::TRIPLE_DAYS_BEFORE_START.to_i).days
      check_in - days
    end

    def second_pay_date
      days = (TravelService::Preference::DUAL_DAYS_BEFORE_START.to_i).days
      check_in - days
    end


  end

end
