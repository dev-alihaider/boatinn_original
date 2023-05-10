class AdminMailer < ApplicationMailer

  def notify_admins_about_review_report(report)
    return if admins_emails.blank?

    @report = report

    # TODO: Add i18n for each admin mail
    # I18n.locale = admin_email.language

    mail(to: admins_emails, subject: t('reports.email_subjects.review_report'))
  end

  # For details about `reason_id` see `reports` in `config/locales/en.yml`.
  def notify_admins_about_user_report(report)
    return if admins_emails.blank?

    @report = report
    @report_reason_section = if @report.reason.between?(4, 8)
                               1
                             elsif @report.reason.between?(9, 11)
                               2
                             else # 12..16
                               3
                             end

    mail(to: admins_emails, subject: t('reports.email_subjects.user_report'))
  end

  def manual_email(content, email_recipient, subject)
    @content = content
    mail(to: email_recipient, subject: subject)
  end

  private

  def admins_emails
    User.where(admin: true).pluck(:email)
  end
end