# frozen_string_literal: true

module Admin
  class UsersController < GeneralController # :nodoc:
    before_action :set_user, except: :index
    before_action :restrict_action_on_yourself!, only: %i[block
                                                          unblock
                                                          make_admin
                                                          revoke_admin]

    helper_method :sort_column, :sort_direction

    # GET /admin/users
    def index
      if params[:search].present?
        users_by_search
      else
        users_ordered
      end
    end

    def edit
      @current_cv = @user.settings(:your_cv)
      @cvs = { cvs_select: User.cvs_select,
               cvs_license: User.cvs_license,
               cvs_country: User.cvs_country,
               cvs_description: User.cvs_description }
    end

    def update
      update_user_image
      update_cv
      @user.update!(user_params)
      flash_about_changed_email

      # confirm email
      @user.confirm if @user.unconfirmed_email.present?

      sign_in_with_new_password
      redirect_to admin_users_path
    rescue StandardError => error
      flash[:error] = error.message
      redirect_to edit_admin_user_path(params[:id])
    end

    # GET /admin/users/:id/sign_in_as_user
    # Using `#bypass_sign_in` instead of `#sign_in`, because not want to update
    # `last_sign_in_at` and `current_sign_in`.
    def sign_in_as_user
      bypass_sign_in(@user)
      redirect_to root_path
    end

    # GET /admin/users/:id/block
    def block
      @user.update(blocked_at: Time.zone.now)
      flash[:success] = t('admin.dashboard.users.user_is_blocked')
      UserBannedJob.perform_later(@user.id)
      redirect_back(fallback_location: root_path)
    end

    # GET /admin/users/:id/unblock
    def unblock
      @user.update(blocked_at: nil)
      flash[:success] = t('admin.dashboard.users.user_is_unblocked')
      redirect_back(fallback_location: root_path)
    end

    # GET /admin/users/:id/make_admin
    def make_admin
      @user.update(admin: true)
      flash[:success] = t('admin.dashboard.users.user_became_admin')
      redirect_back(fallback_location: root_path)
    end

    # GET /admin/users/:id/revoke_admin
    def revoke_admin
      @user.update(admin: false)
      flash[:success] = t('admin.dashboard.users.user_revoked_admin')
      redirect_back(fallback_location: root_path)
    end

    private

    def sort_column
      if (User.column_names + %w[boats_owner boats_count cancellation])
         .include?(params[:column])
        params[:column]
      else
        'id'
      end
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end

    # Order by name which is a composite field of 8 db columns.
    # Order by boats owner = yes|no.
    def users_ordered
      sort_columns = case sort_column
                     when 'boats_owner' then 'boats.user_id'
                     when 'boats_count' then 'count(boats.id)'
                     when 'cancellation' then
                       'penalizations.current_cancellations'
                     else sort_column
                     end

      @users = User.left_joins(:boats, :penalization)
                   .group('users.id, boats.user_id, penalizations.current_cancellations')
                   .order("#{sort_columns} #{sort_direction}")
    end

    # NOTE: Use Ruby downcase: `params[:search].mb_chars.downcase` instead of
    # PostgreSQL function `ILIKE`.
    def users_by_search
      @users = User.where('email ILIKE :query OR display_name ILIKE :query',
                          query: "%#{params[:search]}%").order(:id)
    end

    def restrict_action_on_yourself!
      return unless current_user_same_in_params?

      flash[:error] = t('admin.dashboard.users.cannot_perform_action_yourself')
      redirect_back(fallback_location: root_path)
    end

    def password_in_params?
      params[:user][:password].present? ||
        params[:user][:password_confirmation].present?
    end

    def user_params
      unless password_in_params?
        %i[password password_confirmation].each { |k| params[:user].delete(k) }
      end

      params[:user].permit(:first_name, :last_name, :gender, :birthday, :email,
                           :phone_number, :phone_verified, :language, :currency,
                           :where_you_live, :describe_yourself, :password,
                           :password_confirmation, :admin, :closed)
    end

    def flash_about_changed_email
      return if @user.unconfirmed_email == @user.reload.unconfirmed_email

      flash[:alert] = I18n.t('devise.registrations.update_needs_confirmation')
    end

    # Sign in current user again after password changing.
    def sign_in_with_new_password
      return unless current_user_same_in_params? && password_in_params?

      bypass_sign_in(@user)
    end

    def set_user
      @user = User.find(params[:id])
    end

    def current_user_same_in_params?
      current_user == @user
    end

    def update_user_image
      return if params[:user][:image].blank?

      @user.create_image if @user.image.blank?
      @user.image.update(attachment: params[:user][:image])
    end

    def update_cv
      User.cvs.each_key do |key|
        @user.settings(:your_cv).update!(key => params[:cv][key])
      end
    end
  end
end
