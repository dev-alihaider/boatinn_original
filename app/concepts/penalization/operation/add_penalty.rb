class Penalization::AddPenalty < Trailblazer::Operation
  extend Contract::DSL

  contract do
    property :user
    property :current_penalty_cents
    property :current_cancellations
    property :currency
    property :amount, virtual: true
  end

  step :find_or_create_penalization
  step :set_current_period
  step :set_amount
  step :set_current_cancellations
  step Contract::Build()
  step Contract::Validate()
  step Contract::Persist()

  def find_or_create_penalization(skill, **)
    unless skill[:params][:user].penalization
      result = Penalization::Create.(params: {user: skill[:params][:user]})
      return fail('can`t create penalization') if result.failure?
    end

    skill[:model] = skill[:params][:user].penalization
  end

  def set_current_period(skill, **)
    params = {
      model: skill[:model],
      period_started_at: skill[:params][:period_started_at],
      period_end_at: skill[:params][:period_end_at]
    }
    Penalization::SetCurrentPeriod.(params: params)
  end

  def set_amount(skill, **)
    return fail('amount not set') if skill[:params][:amount].blank?
    return fail('amount should be Money') if skill[:params][:amount].class.name != 'Money'

    skill[:params][:current_penalty_cents] = skill[:model][:current_penalty_cents] + skill[:params][:amount].cents
    skill[:params][:currency] = TravelService::Preference::PENALIZATION_PENALTY_CURRENCY
  end

  def set_current_cancellations(skill, **)
    skill[:params][:current_cancellations] = skill[:model][:current_cancellations] + 1
  end

end
