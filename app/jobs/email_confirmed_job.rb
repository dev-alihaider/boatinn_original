class EmailConfirmedJob < ApplicationJob

  def perform(user_id)
    user = User.find(user_id)
    NotifyService.welcome_to_service(user)
  end

end