class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale

  def default_url_options( options = {} )
    { locale: I18n.locale }.merge options
  end


  private

    def set_locale
      case params[:locale] 
      when "en", "ja"
        I18n.locale = params[:locale]
      else
        I18n.locale = I18n.default_locale
      end
    end

    def redirect_back_or(default)  
      redirect_to(session[:return_to] || default)
      session.delete(:return_to)
    end

    def store_location
      session[:return_to] = request.url
    end

    def admin_user
      redirect_to('/' + I18n.locale.to_s) unless current_user.admin?
      # redirect_to(root_path) unless current_user.admin?
    end
  

end
