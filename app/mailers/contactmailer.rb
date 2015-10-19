class Contactmailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.contactmailer.send.subject

  def received_email(inquiry)
    @inquiry = inquiry
    mail to: "bchange.sup@gmail.com", subject: "webサイトからお問い合わせがありました。"
  end

  def thanks_email(inquiry)
    @inquiry = inquiry
    mail to: inquiry['email'], subject: I18n.t('contact.inquiry_accepted')   
  end

  def error_email(inquiry)
    @inquiry = inquiry
    mail to: "bchange.sup@gmail.com", subject: "Walletの異常です。"
  end

end
