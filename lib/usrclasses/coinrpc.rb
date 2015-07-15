require 'net/http'
require 'uri'
require 'json'

# in lib/usrclasses
 
class Coinrpc

  @@coinuri = {
    'BTC' => URI.parse( Rails.application.secrets.coin_btc_wallet_key ),
    'LTC' => URI.parse( Rails.application.secrets.coin_ltc_wallet_key ),
    'MONA' => URI.parse( Rails.application.secrets.coin_mona_wallet_key ),
    'DOGE' => URI.parse( Rails.application.secrets.coin_doge_wallet_key )
  }
  @@cointype = @@coinuri.keys

  #   アドレスを作る　getaccountaddress
  def self.getnewaddr(coin_t, accnt)
    com_mthds(coin_t, 'getnewaddress', accnt)
  end

  # transcationを表示
  def self.listtrxs(coin_t, num = nil)
    if num then
      params = ["*", num]
      com_mthds(coin_t, 'listtransactions', params)
    else
      com_mthds(coin_t, 'listtransactions', "*")
    end
  end

  # addr が有効なものかどうかチェックする。
  def self.validateaddr(coin_t, addr)  # validateaddress
    com_mthds(coin_t, 'validateaddress', addr)
    # binding.pry
  end

  # 出金 sendtoaddress
  def self.sendaddr(coin_t, addr, amt )
    params = [addr, Float( amt )]
    #    params = [method: addr, params: amt]
    # binding.pry
    com_mthds(coin_t, 'sendtoaddress', params)
    # fee が発生する場合の処理が必要
  end
  
  def self.gettx(coin_t, txid)
    # binding.pry
    com_mthds(coin_t, 'gettransaction', txid)
  end

  def self.getbal(coin_t)
    # binding.pry
    com_mthds(coin_t, 'getbalance', nil)
  end

  def self.getinfo(coin_t)
    # binding.pry
    com_mthds(coin_t, 'getinfo', nil)
  end

  def self.status(coin_t)
    # return "acutal", "Test" or "Dead"
    begin
      ret = getinfo(coin_t)
    rescue => e
      return "Dead"
    else
      if ret['testnet'] then
        return "Test"
      else
        return "Alive"
      end
    end
  end



  # for debug
  def check_keys
    puts @@cointype
    puts @@coinuri 
  end

private

    def self.com_mthds(coin_t, method, params)

       # ticker のチェック。登録外であれば、例外を発生させる
      raise StandardError, "wrong coin ticker" if !( @@cointype.include?(coin_t) )
 
      # binding.pry
      # puts params
      # puts "in coinrpc"
      #Params は配列, 可変長でないので*をつけない。
      if params.nil? then
        params = []  # これで、引数を与えていないことになる。
      elsif !(params.is_a?(Array)) then
        temp = params
        params = []
        params << temp  # 要素一つの配列になる。引数を一つ与えたことになる。
      end
      post_body = { 'method' => method, 'params' => params, 'id' => 'jsonrpc' }.to_json
      resp = JSON.parse( http_post_request(coin_t, post_body) )


      raise JSONRPCError, resp['error'] if resp['error']   # ほかの部分のdebugするので、とりあえず外す。4/6
      resp['result']
    end

    def self.http_post_request(coin_t, post_body)
      uri = @@coinuri[ coin_t ]
      http    = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth uri.user, uri.password
      request.content_type = 'application/json'
      request.body = post_body
      http.request(request).body
    end

    class JSONRPCError < RuntimeError; end

end
