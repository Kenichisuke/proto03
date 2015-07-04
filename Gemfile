source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'

# Use sqlite3 as the database for Active Record
# gem 'sqlite3'

# Use mysql as the database for Active Record
gem 'mysql2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'bootstrap-sass', '~> 3.3.5'
gem 'sprockets'
gem 'devise'
gem 'whenever', :require => false
gem 'active_decorator' # 使っていない
gem 'kaminari'
gem 'rails-i18n'
gem 'rails_admin'


group :development, :test do
  # # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  #gem 'spring', '1.3.3'
  # runnerを試そうとして、rails runner を走らせたら、
  # There is a version mismatch between the spring client and the server.
  # You should restart the server and make sure to use the same version.
  # CLIENT: 1.3.4, SERVER: 1.3.3
  # というメッセージが出たので、指定なしから　1.3.3　に変更した。 
  gem 'rspec-rails'
  
  gem 'pry-rails'  # rails console(もしくは、rails c)でirbの代わりにpryを使われる
  gem 'pry-doc'    # methodを表示
  gem 'pry-byebug' # デバッグを実施(Ruby 2.0以降で動作する)
  gem 'pry-stack_explorer' # スタックをたどれる

  gem 'hirb'          #active record の出力を整形
  # gem 'hirb-unicode'  #hirab で日本語などを出力できるようにする
  
  gem 'better_errors' # errorの時に多くの情報が表示される
  gem 'binding_of_caller' # エラー時のコマンド操作ができる

  gem 'annotate' # schema や routing の情報をファイルに書き加えてくれる。

end

group :test do
  gem 'factory_girl_rails'
end

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
