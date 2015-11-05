include ApplicationHelper

def sign_in(user)
  visit new_user_session_path
  fill_in "メールアドレス", with: user.email
  fill_in "パスワード", with: user.password
  click_button "ログイン"
end

# def sign_in(user, options={})
#   if options[:no_capybara]
#     # Capybaraを使用していない場合にもサインインする。
#     remember_token = User.new_remember_token
#     cookies[:remember_token] = remember_token
#     user.update_attribute(:remember_token, User.encrypt(remember_token))
#   else
#     visit new_user_session_path
#     fill_in "メールアドレス", with: user.email
#     fill_in "パスワード", with: user.password
#     click_button "ログイン"
#   end
# end

