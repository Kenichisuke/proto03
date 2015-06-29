module OrdersHelper
  def order_flag(status)
  	case  status 
    when "open_new" then
  	  t('order.flag.open_new')
    when "open_per" then
  	  t('order.flag.open_per')
    when "noex_cncl" then
  	  t('order.flag.noex_cncl')
    when "exec_cncl" then
  	  t('order.flag.exec_cncl')
    when "noex_expr" then
  	  t('order.flag.noex_expr')
    when "exec_expr" then
  	  t('order.flag.exec_expr')  	  
    when "exec_exec" then
  	  t('order.flag.exec_exec')
    end
  end

  def order_buysell(buysell)
  	if buysell then
      t('order.sell')
  	else
      t('order.buy')
  	end
  end

  def trade_flag(status)
    case status
    when "tr_close" then
      t('trade.flag.tr_close')
    when "tr_cncl" then
      t('trade.flag.tr_cncl')
    when "tr_expr" then
      t('trade.flag.tr_expr')
    end
  end

end
