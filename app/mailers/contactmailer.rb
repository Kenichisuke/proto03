class Contactmailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.contactmailer.send.subject

  # ユーザからのお問い合わせ、自分へ
  def received_email(inquiry)
    @inquiry = inquiry
    mail to: "bchange.sup@gmail.com", subject: "webサイトからお問い合わせがありました。"
  end

  # ユーザからのお問い合わせ、ユーザへ
  def thanks_email(inquiry)
    @inquiry = inquiry
    mail to: inquiry['email'], subject: I18n.t('contact.inquiry_accepted')   
  end

  # emailが送れるのかテストをするため。Adminのメニュー
  def test_email(inquiry)
    @inquiry = inquiry
    mail to: inquiry['email'], subject: "This is Test mail for validation"
  end

  # 例外が起こった時のお知らせ。自分へ。
  def error_email(inquiry)
    @inquiry = inquiry
    mail to: "bchange.sup@gmail.com", subject: "Walletの異常です。"
  end

  # depth のデータがおかしい。自分へ。
  def error_depth_email(inquiry)
    @inquiry = inquiry
    mail to: "bchange.sup@gmail.com", subject: "depth dataの異常です。"
  end


end
