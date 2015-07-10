class StaticPagesController < ApplicationController

  def explanation
    @headinfo="explanation"
  end

  def contact_new
    @headinfo="contact"
  end

  def contact_create
  	mailcont = contact_create_params
    Contactmailer.received_email(mailcont).deliver
    Contactmailer.thanks_email(mailcont).deliver
  	flash[ :notice ] = I18n.t('contact.inquiry_accepted')
    redirect_to('/' + I18n.locale.to_s)
  end

  private
    def contact_create_params
      params.permit(:email, :title, :content)
    end
end
