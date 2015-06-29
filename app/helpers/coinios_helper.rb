module CoiniosHelper
  def coinio_category(categ)
  	case categ
    when "tx_receive" then
  	  t('coinio.category.tx_receive')
    when "tx_immature" then
  	  t('coinio.category.tx_immature')
    when "tx_generate" then
  	  t('coinio.category.tx_generate')
    when "tx_send" then
  	  t('coinio.category.tx_send')
    end
  end

  def coinio_flag(status)
  	case status
    when "in_yet" then
  	  t('coinio.flag.in_yet')
    when "in_done" then
  	  t('coinio.flag.in_done')
    when "out_sent" then
  	  t('coinio.flag.out_sent')
    when "out_abnormal" then
  	  t('coinio.flag.out_abnormal')
    when "out_reserve" then
  	  t('coinio.flag.out_reserve')
    when "out_r_sent" then
  	  t('coinio.flag.out_r_sent')
    when "out_r_n_cncl" then
  	  t('coinio.flag.out_r_n_cncl')
    when "out_r_n_acnt" then
  	  t('coinio.flag.out_r_n_acnt')
    when "out_r_n_addr" then
  	  t('coinio.flag.out_r_n_addr')
    end
  end
end
