# frozen_string_literal: true

class ProfileController < GeneralUsersController # :nodoc:
  before_action :ensure_target_user

  # GET (/:locale)/profile/:id
  def show
    @boats = @user.boats.enabled.finished.by_date_desc
    @reviews_box = reviews_box
  end

  def reviews
    render partial: 'shared/profile/review', collection: reviews_box.collection, as: :review, layout: false
  end

  private

  def reviews_box
    CollectionBoxService.new(@user.reviews_about.by_date_desc, params, limit: UsersHelper::REVIEWS_TO_SHOW)
  end

  def ensure_target_user
    @user = User.find(params[:id]).decorate
  end
end
