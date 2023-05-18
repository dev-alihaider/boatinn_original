# frozen_string_literal: true

class AddSourceNameToPayment < ActiveRecord::Migration[5.1] # :nodoc:
  def up
    add_column :payments, :source_name, :string

    # Payment.find_each do |payment|
    #   card = UserCreditCard.find_by(id: payment.source_id)
    #   if card.present?
    #     payment.update(source_name: "#{card.brand} #{card.number}")
    #   end
    # end
  end

  def down
    remove_column :payments, :source_name, :string
  end
end
