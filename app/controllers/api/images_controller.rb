# frozen_string_literal: true

module Api
  # REST JSON API for images: user can remove own boat images.
  class ImagesController < Api::GenericController
    before_action :authenticate_user!, :authorize_user!
    before_action :validate_update_params!, only: :update

    # POST /api/boats/:boat_id/images.json
    def create
      boat = current_user.boats.find(params[:boat_id])

      validate_max_count!(boat)

      @image = boat.images.create!(attachment: params[:file],
                                   priority: params[:priority] || 0)

      initiate_image_update_job(boat)
      render status: :created if @image
    end

    # PATCH/PUT /api/boats/:boat_id/images/:id.json
    def update
      boat = current_user.boats.find(params[:boat_id])
      image = boat.images.find(params[:id])
      initiate_image_update_job(boat)

      previous_updated_at = image.updated_at

      image.update(priority: params[:priority].to_i)

      head :not_modified if image.updated_at == previous_updated_at
    end

    # DELETE /api/boats/:boat_id/images/:id.json
    def destroy
      current_user.boats.find(params[:boat_id]).images.find(params[:id]).destroy
    end

    private

    def validate_update_params!
      return if params.key?(:priority)

      raise ArgumentError, 'Please include `priority` request param.'
    end

    # Validate maximum uploaded images count.
    #
    # NOTE: This validation located here but not in Boat/BoatImage model because
    # model validation first create image and then raise exception.
    # This code raise error and rollback image creation (saving to disk).
    def validate_max_count!(boat)
      return unless boat.images.count + 1 > Boat::MAX_IMAGES

      boat.errors.add(
        :images,
        I18n.t('activerecord.errors.messages.too_many_attachments',
               count: Boat::MAX_IMAGES)
      )
      raise ActiveModel::ValidationError, boat
    end

    def user_have_rights?
      current_user.boats.exists?(params[:boat_id])
    end

    def authorize_user!
      return if user_have_rights?

      json_response(
        { error: 'Forbidden',
          message: "You don't have permission to perform this action" },
        status(:forbidden)
      )
    end

    def initiate_image_update_job(boat)
      redis_key = "boat_image_updated_job_#{boat.id}"
      return if $redis.get(redis_key)

      interval = 1.hour
      ListingImageUpdatedJob.set(wait_until: interval.from_now).perform_later(boat.id)
      $redis.set(redis_key, 'true', ex: interval)
    end
  end
end
