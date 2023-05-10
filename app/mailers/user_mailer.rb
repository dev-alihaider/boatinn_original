# frozen_string_literal: true

class UserMailer < ApplicationMailer # :nodoc:


  def welcome_email(user)
    user_email user do |email|
      @locals = { name: user.display_name, service_name: t('service_name') }
      subject = t("user_mailer.welcome_email.subject", @locals)
      mail(to: email, subject: subject)
    end
  end

  def welcome_email_promo(nameclient,emailclient)
      @nameclient = nameclient
      @emailclient = emailclient
      subject = @nameclient + " ha dado su consentimiento"
      mail(to: "info@boatinn.net", subject: subject)
  end

  def user_banned(user)
    user_email user do |email|
      subject = t("user_mailer.user_banned.subject")
      mail(to: email, bcc: "rfs@boatinn.net", subject: @subject) 
    end
  end

  def phone_number_deleted(user, phone_number)
    @phone_number = phone_number
    user_email user do |email|
      subject = t("user_mailer.phone_number_deleted.subject")
      mail(to: email, subject: subject)
    end
  end

  def phone_number_updated(user, old_phone_number)
    @old_phone_number = old_phone_number
    user_email user do |email|
      subject = t("user_mailer.phone_number_updated.subject")
      mail(to: email, subject: subject)
    end
  end

  def ask_think_about_boat(boat, user)
    user_email user do |email|
      subject = t("email_subjects.ask_think_about_boat")
      mail(to: email, subject: subject)
    end
  end

  def password_changed(user)
    user_email user do |email|
      subject = t("user_mailer.password_changed.subject")
      mail(to: email, bcc: "rfs@boatinn.net", subject: @subject)
    end
  end

end
