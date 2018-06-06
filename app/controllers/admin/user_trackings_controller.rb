class Admin::UserTrackingsController < Admin::BaseController
  layout "tracking"
  def index
  end

   def show_details
    @q = SearchParams.new(params[:search_params] || {})  
    @uuids = cache_read("user_uuids_list")||[]
  end
  	
  def analysis
    @user = User.find_by(id:params[:em_id].to_i) if params[:em_id].to_i > 0
    @opxpid = params[:opxpid]
    @message = cache_read("#{@opxpid}_user_message")||{}
    @urls = cache_read("#{@opxpid}_user_url_list")&.reverse||[]
    valid_keys = cache_read("#{@opxpid}_user_tags")
    @tags = user_tracking_tag.slice(*valid_keys).values.to_s
  end

  # 手动清除并同步所有缓存
  def delete_tracking
    Ad::UserTracking.load_tracking
  end

  # 手动百度转化
  def analysis_tracking
    Ad::BaiduTracking.load_tracking
  end

  # 热度分析
  def hot_analysis
    @hot = params[:hot_tag]
    @hot_tag = user_tracking_tag[params[:hot_tag]]
    @uuids = cache_read("#{@hot}_user_uuids")||[]
  end

  # 切换图表
  def get_chart
    @chart_name = params[:chart_name]
  end

  # 客户分析
  def user_analysis
    # 客户标签

    # 产品交易

    # 信用

    # 相似比对

  end

end
