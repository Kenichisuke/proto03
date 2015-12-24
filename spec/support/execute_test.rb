class ExecuteTest

  def initialize(coin1, coin2)
    @coin1 = coin1
    @coin2 = coin2
    @mode = "acnt_init"
    # @fileindex = File.open("spec/factories/orderbook_data.txt", "r")
    @fileindex = File.open("spec/factories/book_make_data.txt", "r")
  end

  def find_no( no )
    @fileindex.each_line do | line |
      com = line.strip.downcase
      if com[0..1] == "no" then
        puts line
        dummy, data_no = com.split
        if data_no == no.to_s then
          return true
        end
      end
    end
    # @fileindex.close
    return false
  end

  def read_data_create_orders
    @fileindex.each_line do | line |
    	com = line.strip.downcase
      # binding.pry
      if com.include?("acnts_init") or com.include?("orders_init") then
        @mode = com
        # puts @mode
      elsif com == "end" then
        @mode = com        
        @fileindex.close
        # puts "User:#{User.count}, Acnt: #{Acnt.count}, Order: #{Order.count}, Trade:#{Trade.count}"
        return
      elsif com.chr == "#" || com == '¥n'  || com[0..1] == "no" then
        # do nothing
      elsif com == "acnts_results" || com == "orders_results" then
        @mode = com        
        return
      else
        case @mode
        when "acnts_init" then
          user_tmp, coin_tmp, bal, locked_bal = line.split
          FactoryGirl.create(:acnt, user: user_return(user_tmp), 
            cointype: coin_return(coin_tmp), balance: bal, locked_bal: locked_bal)
        when "orders_init" then
          user_tmp, buysell, rate, amt_a_org, amt_a, flag = line.split
          amt_b     = amt_a.to_f     * rate.to_f
          amt_b_org = amt_a_org.to_f * rate.to_f          
          FactoryGirl.create(:order, user: user_return(user_tmp), 
            coin_a: @coin1, coin_b: @coin2,
            amt_a: amt_a, amt_a_org: amt_a_org,
            amt_b: amt_b, amt_b_org: amt_b_org, rate: rate, 
            buysell: buysell, flag: flag.to_sym)
        end
      end
    end
  end

  def check_data
    check = true
    @fileindex.each_line do | line |
      com = line.strip.downcase
      # puts line
      # puts com
      # binding.pry
      if com.include?("acnts_results") or com.include?("orders_results") then
        @mode = com
      elsif com == "end" then
        @mode = com
        @fileindex.close
        return check
      elsif com.chr == "#" || com == '¥n' || com[0..1] == "no" then
        # do nothing
      elsif com == "acnts_init" || com == "orders_init" then
        @mode = com
        # puts "I am #{@mode}"
        return check
      else
        case @mode
        when "acnts_results" then
          user_tmp, coin_tmp, bal, locked_bal = line.split
          acnts = Acnt.where(user: user_return(user_tmp), cointype: coin_return(coin_tmp), 
            balance: bal, locked_bal: locked_bal)
          if acnts.count != 1 then
            # binding.pry
            check = false
            p line
            p "acnts",  acnts.count
          end
        when "orders_results" then
          # ロジックは、完全には正しくない。同じデータが複数ある場合に対応していない。
          user_tmp, buysell, rate, amt_a_org, amt_a, flag = line.split
          amt_b     = amt_a.to_f     * rate.to_f
          amt_b_org = amt_a_org.to_f * rate.to_f
          tf = buysell =~ /^true$/i ? true : false  # true, false が文字列として扱われて、正しく動かないのでこの行を加えた。
          ords = Order.where(user: user_return(user_tmp), coin_a: @coin1, coin_b: @coin2,
            amt_a: amt_a, amt_a_org: amt_a_org,
            amt_b: amt_b, amt_b_org: amt_b_org, 
            rate: rate, 
            buysell: tf, flag: flag)
          if ords.count == 0 then
            # binding.pry
            check = false
            p line.strip
            p "orders: " + ords.count.to_s
            p "user: " + user_return(user_tmp).id.to_s
            p "buysell: " + buysell
            p "rate: " + rate
            p "amt_a: " + amt_a
            p "amt_a_org: " + amt_a_org
          end
        end
      end
    end
    return check
  end

  # def continue?
  #   puts "continue called. mode #{@mode}"
  #   if @mode == "end" then
  #     return false
  #   else
  #     return true
  #   end
  # end

  def show_data
    lst = User.all
    lst.reload
    puts "Users: #{User.count}"
    lst.each do | user |
      puts "User:#{user.id} admin:#{user.admin}"
    end

    lst = Acnt.all
    lst.reload
    puts "Acnts: #{Acnt.count}"
    lst.each do | acnt |
      puts "User:#{acnt.user_id} coinid:#{acnt.cointype_id} balance:#{acnt.balance} locked_bal:#{acnt.locked_bal}"
    end

    puts "Orders: #{Order.count}"
    puts "open"
    lst = Order.where(coin_a: @coin1, coin_b: @coin2).openor.order(rate: :DESC)
    lst.reload
    lst.each do | ord |
      puts "id:#{ord.id} user:#{ord.user_id} buysell:#{ord.buysell} rate:#{ord.rate} amt_a_org:#{ord.amt_a_org}  amt_a:#{ord.amt_a} amt_b_org:#{ord.amt_b_org} amt_b:#{ord.amt_b} flag:#{ord.flag}"
    end

    puts "closed"

    lst = Order.where(coin_a: @coin1, coin_b: @coin2).where('flag > 8').order(rate: :DESC)
    lst.reload
    lst.each do | ord |
      puts "id:#{ord.id} user:#{ord.user_id} buysell:#{ord.buysell} rate:#{ord.rate} amt_a_org:#{ord.amt_a_org}  amt_a:#{ord.amt_a} amt_b_org:#{ord.amt_b_org} amt_b:#{ord.amt_b} flag:#{ord.flag}"
    end

    puts "Trade: #{Trade.count}"
    lst = Trade.all
    lst.reload
    lst.each do | trd |
      puts "order_id:#{trd.order_id} amt_a:#{trd.amt_a} amt_b:#{trd.amt_b} flag:#{trd.flag}"
    end
  end

  def file_close
      @fileindex.close
  end


  private
    def user_return(user)
      if user == "1" then
        return User.first
      elsif user == "2" then
        return User.second
      elsif user == "3" then
        return User.third
      elsif user == "4" then
        return User.fourth
      else
        p user
        raise "invalid user alias number! #{user}"
      end
    end

    def coin_return(coin)
      if coin == "1" then
        return @coin1
      elsif coin == "2" then
        return @coin2
      else
        p coin
        raise "invalid coin alias number! #{coin}"
      end
    end


end
