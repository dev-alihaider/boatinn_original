# frozen_string_literal: true

class PrewizardsController < GeneralUsersController # :nodoc:
  def index
    @prewizard_settings = PrewizardSetting.try(:last)
    faqs_general = Faq.visible.general.order(:order)
    faqs_for_renters = Faq.visible.for_renters.order(:order)
    faqs_for_owners = Faq.visible.for_owners.order(:order)
    @faqs = faqs_general + faqs_for_renters + faqs_for_owners

    @three = (1..3).to_a
    @four = (1..4).to_a
  end
end
