class Penalization::SetCurrentPeriod < Trailblazer::Operation

  step :process

  def process(skill, **)
    penalization = skill[:params][:model]

    return fail('model not set') if skill[:params][:model].blank?
    return true if penalization.period_end_at && penalization.period_end_at > Time.zone.now

    duration = TravelService::Preference::PENALIZATION_PERIOD_DURATION
    penalization.period_started_at ||= Time.zone.now
    penalization.period_end_at ||= penalization.period_started_at + duration
  end
end
