require 'zaif'

class ApiZaif < Zaif::API

# btc, mona と jpy の任意の組み合わせ 2015/12/21

  mattr_accessor :logger
  self.logger ||= Rails.logger

  def initialize
    @api = Zaif::API.new
    class << @api
      def zero_cool_down
        @cool_down = false        
      end
    end
    @api.zero_cool_down
  end

  def get_last_price(c1t, c2t)
    begin
      val = @api.get_last_price(c2t.downcase, c1t.downcase)
    rescue => e
      logger.error('Zaif connection error.')
      logger.error('class:' + e.class.to_s)
      logger.error('msg:' + e.message)
      raise $!
    else
      if val.nonzero? then
        1.0 / val
      else
        0
      end
    end
  end

  # def get_ticker(c1t, c2t = "jpy")
  #   begin        
  #     @api.get_ticker(c1t, c2t)
  #   rescue => e
  #     logger.error('Zaif connection error.')
  #     logger.error('class:' + e.class.to_s)
  #     logger.error('msg:' + e.message)
  #     raise $!
  #   end
  # end

end


