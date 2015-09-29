module ApplicationHelper
  def full_seo(type, cont)
    if cont.empty?
      str = 'app_html.' + type + '.default'
    else  
      str = 'app_html.' + type + '.' + cont
    end
    t(str)
  end

end
