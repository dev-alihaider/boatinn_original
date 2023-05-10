# == Schema Information
#
# Table name: travel_invoices
#
#  id            :bigint(8)        not null, primary key
#  booking_id    :bigint(8)
#  client_number :string
#  seller_number :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Travel::Invoice < ApplicationRecord
  belongs_to :booking, class_name: 'Travel::Booking'
  INVOICE_NUMBER_FORMAT = 'YEAR0000000000'

  def self.generate_new_numbers(booking_id)
    last_id = self.last&.id
    next_for_client = last_id.present? ? (last_id * 2 + 1) : 1
    next_for_seller = next_for_client + 1
    self.create(
      booking_id: booking_id,
      client_number: self.build_number_for(next_for_client),
      seller_number: self.build_number_for(next_for_seller),
     )
  end


  def self.build_number_for(next_id)
    invoice_number_length = INVOICE_NUMBER_FORMAT.length
    next_id_length = next_id.to_s.length
    begin_id_pos = invoice_number_length - next_id_length
    number = "#{INVOICE_NUMBER_FORMAT[0, begin_id_pos]}#{next_id}"
    number.sub('YEAR', Time.zone.now.year.to_s)
  end
end
