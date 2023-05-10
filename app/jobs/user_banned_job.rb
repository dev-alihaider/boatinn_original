class UserBannedJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)
    NotifyService.user_banned(user)
  end
end
