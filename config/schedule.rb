# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#

every 1.minutes do 
#   # orderbook を約定させ、trade をacntに書き込み、orderbook の表示を作る。 
  runner "Orderbook.totalprocess"
end

every 7.minutes do  
  # PriceHistのデータを作り、Plotを作る
  runner "Pricehistproc.totalprocess"
end

every 2.minutes do 
  # Walletをチェックし、AcntをUpdateする。
  runner "Walletcheck.totalprocess"
end

# Learn more: http://github.com/javan/whenever
