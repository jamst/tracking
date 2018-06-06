class UserTrackingsController < ApplicationController
  # js请求	
  def index
  	tracking_hash = {}
    # 本机作为第三方的cookie
    tracking_hash[:opxPID] = cookies[:opxPID]
    # 宿主网站cookie
    tracking_hash[:time_now] = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    tracking_hash[:domain] = request.raw_host_with_port
    tracking_hash[:opxtitle] = params[:opxtitle] 
    tracking_hash[:opxreferrer] = CGI.unescape(CGI.unescape(params[:opxreferrer]))
    tracking_hash[:opxurl] = CGI.unescape(params[:opxurl])
    tracking_hash[:opxid] = params[:opxid]
    tracking_hash[:ip] = (request.env['HTTP_X_FORWARDED_FOR'].present? ? request.env['HTTP_X_FORWARDED_FOR'] : request.remote_ip).split(",").first
    tracking_hash[:opxuserAgent] = CGI.unescape(params[:opxuserAgent]) 

    # 统计游客url浏览记录
    cache_array("#{cookies[:opxPID]}_user_url_list",tracking_hash)
    cache_sum("#{cookies[:opxPID]}_user_uuids")
    
    unless cache_read("user_uuids_list") && (cache_read("user_uuids_list").include? cookies[:opxPID])
      # uuids数统计加1
      cache_sum("user_uuids")
      # 首次登录信息
      cache_value("#{cookies[:opxPID]}_user_message",tracking_hash)
    end

    # uuid添加进数组
    cache_array("user_uuids_list",cookies[:opxPID],"uniq")

    # 当前用户关联
    if params[:opxid].to_i != 0
      cache_value(cookies[:opxPID],params[:opxid].to_i) 
    end

    # 根据url来触发响应
    user_tracking_tag.keys.each do |_|
      if params[:opxurl].include? _.to_s
        cache_sum(_)
        cache_array("#{_}_user_uuids",cookies[:opxPID],"uniq") 
        cache_array("#{cookies[:opxPID]}_user_tags",_,"uniq")
        cache_sum("#{cookies[:opxPID]}_user_#{_}")
      end
    end

    # 日志处理
    #Tracking << tracking_hash
    return render :js => ""
  end


  # 显示广告
  def image_ad
    # 添加曝光记录（记录广告曝光）
    # link添加跳转服务器后再跳转link（记录广告点击）
    # event_data (转化记录)
    opxpid = cookies[:opxPID]

    tracking_hash = {}
    # 本机作为第三方的cookie
    tracking_hash[:opxPID] = opxpid
    # 宿主网站cookie
    tracking_hash[:height] = params[:height]
    tracking_hash[:width] = params[:width]
    tracking_hash[:time_now] = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    tracking_hash[:domain] = request.raw_host_with_port
    tracking_hash[:opxtitle] = params[:opxtitle] 
    tracking_hash[:opxreferrer] = CGI.unescape(CGI.unescape(params[:opxreferrer]))
    tracking_hash[:opxurl] = CGI.unescape(params[:opxurl])
    tracking_hash[:opxid] = params[:opxid]
    tracking_hash[:ip] = (request.env['HTTP_X_FORWARDED_FOR'].present? ? request.env['HTTP_X_FORWARDED_FOR'] : request.remote_ip).split(",").first
    tracking_hash[:opxuserAgent] = CGI.unescape(params[:opxuserAgent]) 

    link,src,campaign_id,creative_id = MyTag.match_ad(tracking_hash)

    # 广告曝光记录
    link = "/user_trackings/click_data?jump="+ link + "&campaign_id=" + campaign_id.to_s + "&creative_id=" + creative_id.to_s + "&height=" + params[:height].to_s + "&width=" + params[:width].to_s + "&opxtitle="+params[:opxtitle].to_s+"&opxurl="+params[:opxurl].to_s+"&opxreferrer="+params[:opxreferrer].to_s+"&opxid="+params[:opxid].to_s+"&opxuserAgent="+params[:opxuserAgent].to_s
    tracking_hash[:campaign_id] = campaign_id
    tracking_hash[:creative_id] = creative_id
    cache_array("#{opxpid}_exposure_url_list",tracking_hash)

    render :json => {link:link,src:src}
  end


  # 广告点击跳转
  def click_data
    opxpid = cookies[:opxPID]
    tracking_hash = {}
    # 本机作为第三方的cookie
    tracking_hash[:opxPID] = opxpid
    # 宿主网站cookie
    tracking_hash[:height] = params[:height]
    tracking_hash[:width] = params[:width]
    tracking_hash[:time_now] = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    tracking_hash[:domain] = request.raw_host_with_port
    tracking_hash[:opxtitle] = params[:opxtitle] 
    tracking_hash[:opxreferrer] = CGI.unescape(CGI.unescape(params[:opxreferrer]))
    tracking_hash[:opxurl] = CGI.unescape(params[:opxurl])
    tracking_hash[:opxid] = params[:opxid]
    tracking_hash[:ip] = (request.env['HTTP_X_FORWARDED_FOR'].present? ? request.env['HTTP_X_FORWARDED_FOR'] : request.remote_ip).split(",").first
    tracking_hash[:opxuserAgent] = CGI.unescape(params[:opxuserAgent]) 
    tracking_hash[:campaign_id] = params[:campaign_id]
    tracking_hash[:creative_id] = params[:creative_id]
   
    cache_array("#{opxpid}_click_url_list",tracking_hash)

    redirect_to params[:jump]
  end


  # 广告转化记录
  def event_data
    opxpid = cookies[:opxPID]

    tracking_hash = {}
    # 本机作为第三方的cookie
    tracking_hash[:opxPID] = opxpid
    # 宿主网站cookie
    tracking_hash[:time_now] = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    tracking_hash[:domain] = request.raw_host_with_port
    tracking_hash[:opxtitle] = params[:opxtitle] 
    tracking_hash[:opxreferrer] = CGI.unescape(CGI.unescape(params[:opxreferrer]))
    tracking_hash[:opxurl] = CGI.unescape(params[:opxurl])
    tracking_hash[:opxid] = params[:opxid]
    tracking_hash[:ip] = (request.env['HTTP_X_FORWARDED_FOR'].present? ? request.env['HTTP_X_FORWARDED_FOR'] : request.remote_ip).split(",").first
    tracking_hash[:opxuserAgent] = CGI.unescape(params[:opxuserAgent]) 
    tracking_hash[:campaign_id] = params[:campaign_id]
    tracking_hash[:creative_id] = params[:creative_id]
    tracking_hash[:event_no] = params[:event_no]
   
    cache_array("#{opxpid}_event_url_list",tracking_hash)

    return render :js => ""
  end

end
