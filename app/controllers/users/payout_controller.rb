# frozen_string_literal: true
# this controller is deprecated and not usable
# recommend to destroy, service switched stripe express account
module Users
  class PayoutController < GeneralUsersController # :nodoc:
    before_action :authenticate_user!
    before_action :find_payout, except: [:create, :verification]
    after_action :save_account_verify, only: %i[verification]

    def create
      User.transaction do
        sa = StripeActionsService.new.account_id(current_user, params[:country_name],
                                                 request.remote_ip, params[:account_holder_type])
        StripeActionsService.new.create_bank_account(current_user, sa, params)
      end
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to payout_dashboard_account_index_path
    end

    def verification
      stripe_user_id = current_user.stripe_account.stripe_user_id
      @account = StripeActionsService.new.retrieve_stripe_account(stripe_user_id)
      params[:verification].each do |p|
        apply_account_val(p)
      end
      @account.save
    rescue StandardError => e
      @error = e.message
    end

    def set_default
      ActiveRecord::Base.transaction do
        current_user.user_payouts.update_all(payout_default: false)
        payout = current_user.user_payouts.find(params[:id])
        payout.update_attributes!(payout_default: true)
      end
      head :ok
    end

    def destroy
      @payout.destroy
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to payout_dashboard_account_index_path
    end

    private

    def find_payout
      @payout = UserPayout.find(params[:id])
    end

    def params_uba
      params[:user_bank_account].permit(:account_holder_name,
                                        :bank_name, :swift, :iban)
    end

    def apply_account_val(p)
      pass = p.split('.')
      count = pass.size
      if count > 1
        dummy_for_owners(p, pass)
        return if params[:verification][p].blank?
        account_var(pass, count, p)
      else
        @account.send("#{p}=", params[:verification][p])
      end
    end

    def account_var(pass, count, p)
      val = params[:verification][p]
      if count == 2
        @account.send(pass.first).send("#{pass.second}=", val)
      elsif count == 3
        if p == 'legal_entity.verification.document'
          val = upload_document(p)
        end
        @account.send(pass.first).send(pass.second).send("#{pass.third}=", val)
      end
    end

    def dummy_for_owners(p, pass)
      if p == 'legal_entity.additional_owners'
        @account.send(pass.first).send("#{pass.second}=", nil)
      end
    end

    def upload_document(p)
      par = { purpose: 'identity_document', file: params[:verification][p] }
      file = Stripe::FileUpload.create(par)
      file['id']
    end

    def save_account_verify
      if current_user.stripe_account&.verified?
        current_user.stripe_account.update_column(:account_verified, true)
      end
    end
  end
end
