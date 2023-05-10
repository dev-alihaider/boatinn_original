# frozen_string_literal: true

class Travel::MessageCreatedJob < ApplicationJob

  def perform(message_id)
    current_message = ::Travel::Message.find_by(id: message_id)
    update_user_responce_rate(current_message)
    notify_users(current_message) if current_message.message?
  end

  # update response only for first message from seller
  def update_user_responce_rate(current_message)
    seller = current_message.trip.seller
    return unless seller.id == current_message.sender.id
    first_message = current_message.trip.messages.where(sender_id: seller.id).first
    return unless first_message.id == current_message.id
    ::ResponseRateService.reset_user(seller)
  end

  def notify_users(current_message)
    ::NotifyService.new_unread_message(current_message.trip, current_message.sender)
  end

end

