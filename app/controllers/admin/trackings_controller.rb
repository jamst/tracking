class Admin::TrackingsController < ApplicationController
  before_action :find_trackend_targets , only: [:index,:analysis,:hot_analysis,:vip_tracking]
  layout "tracking"
  
  def index
    @uuids = cache_read("uuids_list")||[]
  end
    
  def analysis
    @tracking_init.update(trackend_target:(@trackend_targets << params[:opxpid])) if @tracking_init && !(@trackend_targets.include? params[:opxpid])
    load_detail
  end  

  # 清楚所有缓存
  def delete_tracking
    TrackingRecord.load_tracking
  end

  # 热度分析
  def hot_analysis
    @hot = params[:hot_tag]
    @hot_tag = TRACKING_TAG[params[:hot_tag]]
    @uuids = cache_read("#{@hot}_uuids")||[]
  end

  # 重点关注某一对象
  def vip_tracking
    if @tracking_init && (@tracking_target.include? params[:opxpid])
      @tracking_init.update(tracking_target:(@tracking_target.delete params[:opxpid]) )
    else  
      @tracking_init.update(tracking_target:(@tracking_target << params[:opxpid]) ) 
    end  
    load_detail
  end

  # 循环查询某人数据
  def load_detail
    @employee = Employee.find(params[:em_id].to_i) if params[:em_id].to_i >0
    @opxpid = params[:opxpid]
    @message = cache_read("#{@opxpid}_message")||{}
    @urls = cache_read("#{@opxpid}_url_list").reverse||[]
    valid_keys = cache_read("#{@opxpid}_tags")
    @tags = TRACKING_TAG.slice(*valid_keys).values.to_s
  end

  private

  # 是否已标记／查看过该员工
  def find_trackend_targets
    @tracking_init = TrackingInit.first
    # 已查看过的人
    @trackend_target = @tracking_init&.trackend_target
    # 标记未危险追踪的人
    @tracking_target = @tracking_init&.tracking_target
    @trackend_targets = (@trackend_target & @tracking_target).uniq
  end

end
