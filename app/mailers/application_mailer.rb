# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base # :nodoc:
#  default from: "BoatINN Notifier <#{ENV['SMTP_EMAIL_USER_NAME']}>"
  default from: "BoatINN Notifier <no-reply@boatinn.net>"
  layout 'mailer'
  add_template_helper(ApplicationHelper)
  add_template_helper(LocalizeHelper)
  add_template_helper(MoneyHelper)
  add_template_helper(UsersHelper)
  add_template_helper(EmailHelper)

  def user_email(user, &block)
    @recipient = user
    MoneyHelper.mailer_current_currency = @recipient.currency || Money.default_currency.iso_code
    I18n.locale = @recipient.language if @recipient.language
    block.call(user.email)
  end

end
