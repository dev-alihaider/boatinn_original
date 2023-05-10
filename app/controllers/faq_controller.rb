# frozen_string_literal: true

class FaqController < GeneralUsersController # :nodoc:
  # GET (/:locale)/faq
  def index
    @faqs_general = Faq.general.order(:order)
    @faqs_for_renters = Faq.for_renters.order(:order)
    @faqs_for_owners = Faq.for_owners.order(:order)
  end
end
