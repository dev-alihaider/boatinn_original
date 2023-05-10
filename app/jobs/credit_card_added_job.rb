# frozen_string_literal: true

class CreditCardAddedJob < ApplicationJob

  def perform(card_id)
    credit_card = UserCreditCard.find(card_id)
    NotifyService.credit_card_added(credit_card)
  end

end
