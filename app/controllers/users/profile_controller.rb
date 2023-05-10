# frozen_string_literal: true

module Users
  class ProfileController < GeneralUsersController # :nodoc:
    before_action :authenticate_user!
    before_action :old_email, :unverify_phone_if_new!, only: :update

    def index
      redirect_to edit_dashboard_profile_index_path
    end

    # GET (/:locale)/dashboard/profile
    def show
      @user = current_user.decorate
      @boats = @user.boats.by_date_desc
    end

    def edit
      @user = current_user.decorate
    end

    def photo_update
      return render_no_image_error unless params.dig(:user, :image)
      current_user.create_image if current_user.image.blank?
      current_user.image&.update(attachment: params[:user][:image])
    end

    # DELETE (/:locale)/dashboard/profile/destroy_photo
    def destroy_photo
      if current_user.image.present?
        current_user.image.destroy
      else
        head :not_modified
      end
    end

    def update
      old_phone_number = current_user.phone_number
      current_user.update_attributes!(permit_user)
      if @old_email != current_user.reload.unconfirmed_email
        flash[:alert] = I18n.t('users.profile.check_email')
      end

      if old_phone_number.present? && current_user.phone_number.blank?
        PhoneNumberDeletedJob.perform_later(current_user.id, old_phone_number)
      elsif current_user.phone_number.present? && old_phone_number != current_user.phone_number
        PhoneNumberUpdatedJob.perform_later(current_user.id, old_phone_number)
      end

    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to edit_dashboard_profile_index_path(locale:
                                                      current_user.language)
    end

    # GET (/:locale)/dashboard/profile/reviews
    def reviews
      @reviews = current_user.reviews.by_date_desc
                             .limit(UsersHelper::REVIEWS_TO_SHOW)
      @reviews_about = current_user.reviews_about.by_date_desc
                                   .limit(UsersHelper::REVIEWS_TO_SHOW)
    end

    def cv
      @current_cv = current_user.settings(:your_cv)
      @cvs = { cvs_select: User.cvs_select,
               cvs_license: User.cvs_license,
               cvs_country: User.cvs_country,
               cvs_description: User.cvs_description }
    end

    def update_cv
      User.cvs.each_key do |key|
        current_user.settings(:your_cv).update_attributes! key => params[key]
      end
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to cv_dashboard_profile_index_path
    end

    private

    def permit_user
      params[:user].permit(:first_name, :last_name, :gender,
                           :nie, :birthday, :email, :phone_number,
                           :language, :currency,
                           :where_you_live, :describe_yourself)
    end

    def old_email
      @old_email = current_user.unconfirmed_email
    end

    def unverify_phone_if_new!
      if current_user.phone_verified? &&
         current_user.phone_number_in_database != params[:user][:phone_number]
        current_user.update(phone_verified: false)
      end
    end

    def render_no_image_error
      render json: { error: 'Bad Request',
                     message: 'Request parameter `[user][image]` is empty.' },
             status: :bad_request
    end
  end
end
