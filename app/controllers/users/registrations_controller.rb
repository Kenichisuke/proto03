class Users::RegistrationsController < Devise::RegistrationsController
before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    # super
    build_resource({})
    set_minimum_password_length
    @headinfo="signup"
  end

  # POST /resource
  def create
    super do | user |
      unless user.errors.any? then # エラーがない場合のみ、Acntを作る。これは必要！
        num = user.id + 100_100        
        user.user_num = num.to_s # 重ならないようにするロジック必要, 後でDBのindexを加える。
        coin_ts = Cointype.tickers
        coin_ts.each do | co |
          Acnt.registration(user.id, co, num.to_s)
        end
        user.save
      end
    end
  end

  # GET /resource/edit
  def edit
    # super
    @headinfo="account"
    render :edit
  end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up)
#    devise_parameter_sanitizer.for(:sign_up) << :attribute
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
