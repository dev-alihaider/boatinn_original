# frozen_string_literal: true
#
module Admin
  class MailboxController < GeneralController # :nodoc:
    before_action :parse_composed_data, only: %i[send_composed]
    RECIPIENT_GROUPS = %i[all owners clients manual].freeze

    # compose
    def compose
      @recipient_groups = recipient_groups

    end

    def send_composed
      @parsed_composed_data[:emails].each do |email_rec|
        email = AdminMailer.manual_email(@parsed_composed_data[:content], email_rec, @parsed_composed_data[:subject])
        email.deliver_later
      end

      flash[:notice] = t('admin.mailbox.emails_sent')
      redirect_back(fallback_location: admin_compose_email_path)
    end

    private

    def recipient_groups
      result = []
      RECIPIENT_GROUPS.each do |group|
        result << [I18n.t("admin.mailbox.groups.#{group}"), group]
      end
      result
    end

    def parse_composed_data
      @parsed_composed_data = {
        emails: parse_emails,
        subject: params[:subject],
        content: params[:content]
      }

      if @parsed_composed_data[:emails].blank?
        flash[:error] = t('admin.mailbox.emails_blank')
        redirect_back(fallback_location: admin_path) and return
      end

      if @parsed_composed_data[:subject].blank? || @parsed_composed_data[:content].blank?
        flash[:error] = t('admin.mailbox.subject_or_conent_blank')
        redirect_back(fallback_location: admin_path) and return
      end
    end

    def parse_emails
      case params[:to].to_s.to_sym
      when :all then User.pluck(:email)
      when :owners then User.sellers.pluck(:email)
      when :clients then User.clients.pluck(:email)
      else
        emails = []
        params[:emails].to_s.split("\n").each do |str_row|
          str_row.split(',').each do |email|
            email = email.delete(' ').delete("\r")
            emails << email if email =~ URI::MailTo::EMAIL_REGEXP
          end
        end
        emails.compact.uniq
      end
    end
  end
end
