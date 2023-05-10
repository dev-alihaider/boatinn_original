class PhoneNumberDeletedJob < ApplicationJob
  def perform(user_id, phone_number)
    user = User.find(user_id)
    NotifyService.phone_number_deleted(user, phone_number)
  end
end