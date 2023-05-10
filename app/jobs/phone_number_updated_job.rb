class PhoneNumberUpdatedJob < ApplicationJob
  def perform(user_id, old_phone_number)
    user = User.find(user_id)
    NotifyService.phone_number_updated(user, old_phone_number)
  end
end