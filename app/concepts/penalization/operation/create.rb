class Penalization::Create < Trailblazer::Operation

  step :define_model
  step :assign_currency
  step :set_current_period
  step Contract::Build( constant: Penalization::Contract::Create )
  step Contract::Persist()

  def define_model(skill, **)
    skill[:model] = skill[:params][:user].build_penalization
  end

  def assign_currency(skill, **)
    skill[:params][:currency] = TravelService::Preference::PENALIZATION_PENALTY_CURRENCY
  end

  def set_current_period(skill, **)
    params = {
      model: skill[:model],
      period_started_at: skill[:params][:period_started_at],
      period_end_at: skill[:params][:period_end_at]
    }
    Penalization::SetCurrentPeriod.(params: params)
  end

end
