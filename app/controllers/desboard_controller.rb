class DesboardController < ActionController::Base
  layout "desboard"
  
  def index

  end
  	
  def analysis
    @employee = Employee.find(params[:em_id].to_i)
    @opxpid = params[:opxpid]
    @message = cache_read("#{@opxpid}_message")
    @urls = cache_read("#{@opxpid}_url_list").reverse
    valid_keys = cache_read("#{@opxpid}_tags")
    @tags = TRACKING_TAG.slice(*valid_keys).values.to_s
  end	

  # 清楚所有缓存
  def delete_tracking
    delete_cache
  end

  
end
