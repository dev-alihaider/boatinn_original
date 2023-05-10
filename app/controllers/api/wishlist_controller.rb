# frozen_string_literal: true

module Api
  # REST JSON API for wishlist: user can add/remove own boats.
  class WishlistController < Api::GenericController
    before_action :authenticate_user!, :authorize_user!, :validate_id!

    # POST /api/users/:user_id/wishlist.json
    def create
      current_user.wishes << Boat.find(params[:id])
      current_user.save!
      head :created if current_user.wishes.exists?(params[:id])
    end

    # DELETE /api/users/:user_id/wishlist/:id.json
    def destroy
      current_user.wishes.destroy(Boat.find(params[:id]))
    end

    private

    def user_have_rights?
      current_user.id == params[:user_id].to_i
    end

    def authorize_user!
      return if user_have_rights?

      json_response(
        { error: 'Forbidden',
          message: "You don't have permission to perform this action" },
        status(:forbidden)
      )
    end

    def validate_id!
      return if params[:id].present?

      json_response({ error: 'Bad Request',
                      message: 'Please include :id in request' },
                    status(:bad_request))
    end
  end
end
