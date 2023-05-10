# frozen_string_literal: true

module Api
  # REST JSON API for reporting to admins by e-mail.
  class ReportsController < Api::GenericController
    before_action :authenticate_user!
    before_action :validate_review_params!, only: :about_review
    before_action :validate_user_params!, only: :about_user

    # POST /api/reports/about_review.json
    def about_review
      report = @review.reports_about.create!(author: current_user,
                                             reason: params[:reason_id])

      AdminMailer.notify_admins_about_review_report(report).deliver_now
    end

    # POST /api/reports/about_user.json
    def about_user
      report = @target_user.reports_about.create!(author: current_user,
                                                  reason: params[:reason_id],
                                                  details: params[:details])

      AdminMailer.notify_admins_about_user_report(report).deliver_now
    end

    private

    def validate_review_params!
      validate_param_presence!(:review_id)
      validate_param_presence!(:reason_id)
      validate_reason_id_param! if validate_review_id_param!
    end

    def validate_user_params!
      validate_param_presence!(:target_user_id)
      validate_param_presence!(:reason_id)
      validate_reason_id_param! if validate_user_id_param!
    end

    def validate_param_presence!(param)
      return if params[param].present?

      raise ArgumentError, "Please include `#{param}` request param."
    end

    def validate_review_id_param!
      @review = Review.find(params[:review_id])

      return true if @review.receiver != current_user

      json_response(
        { error: 'Forbidden',
          message: 'You cannot create review report about yourself.' },
        status(:forbidden)
      )

      false
    end

    def validate_user_id_param!
      @target_user = User.find(params[:target_user_id])

      return true if @target_user != current_user

      json_response(
        { error: 'Forbidden',
          message: 'You cannot create user report about yourself.' },
        status(:forbidden)
      )

      false
    end

    # For details about `reason_id` see `reports` in `config/locales/en.yml`.
    def validate_reason_id_param!
      return if params[:reason_id].to_i.between?(1, 16)

      raise ArgumentError, 'Param `reason_id` must be in range 1..16.'
    end
  end
end
