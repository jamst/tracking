class TrackingsController < ActionController::Base
  # js请求	
  def index
  	#p CGI.unescape(params[:opxcookie]) 
    begin
      @cookie_domain = request.env["HTTP_X_DOMAIN_FOR"].to_s.strip unless request.env["HTTP_X_DOMAIN_FOR"].to_s.strip == ""
    rescue
    ensure
      @cookie_domain = ".whmall.test" unless @cookie_domain
    end

  	tracking_hash = {}
    # 本机作为第三方的cookie
    tracking_hash[:opxPID] = cookies[:opxPID]
    # 宿主网站cookie
    tracking_hash[:time_now] = Time.now
    tracking_hash[:domain] = @cookie_domain 
    tracking_hash[:opxtitle] = params[:opxtitle] 
    tracking_hash[:opxreferrer] = params[:opxreferrer] 
    tracking_hash[:opxurl] = params[:opxurl] 
    tracking_hash[:opxid] = params[:opxid] 
    tracking_hash[:ip] = request.env['HTTP_X_FORWARDED_FOR'] || request.env['HTTP_X_REAL_IP'] || request.remote_ip
    tracking_hash[:opxuserAgent] = CGI.unescape(params[:opxuserAgent]) 

    opxcookie = CGI.unescape(params[:opxcookie])
    opxcookie = opxcookie.split(";")
    opxcookie_hash = {}
    opxcookie.each do |c|
      cc = c.strip	
  	  if cc.include? "="
  	  	ccc = cc.split("=")
  	    opxcookie_hash[ccc[0]] = ccc[1]
  	  end  
    end

    tracking_hash[:opxcookie] = opxcookie_hash
    # 日志处理

    # 定义受访页面代号设置

    # mysql只保留当天（开启里实时追踪的用户）实时数据，历史数据在日志里每天清洗入库。

    # 存储到数据库中，id关联
    

    # 是否首次记录
    if cache_read("uuids_list").include? cookies[:opxPID]
      # 统计游客url浏览记录
      cache_write("#{cookies[:opxPID]}_url_list",params[:opxurl])
      if params[:opxid].to_i >= 31415926 * 201314
        
      else  
        # 绑定 opxid & opxPID & domain
      end
    else
      # uuid添加进数组
      cache_array("uuids_list",cookies[:opxPID])
      # uuids数统计加一
      cache_write("uuids")
    end


    # 当天上线通知
    if @book_uuids.include? cookies[:opxPID]
      # opxPID当天页面list(a,b,c,d)
    else
      # 当天在线人数＋1（高频人数，低频人数）（买家人数，卖家人数）
    end

    # 根据url来触发响应
    if params[:opxurl].include?("temporary_reports")
      p 111
      # 产品热点记录叠加统计（产品分类，与到访客户）
      # 某个页面的受访热点（页面热点分布图）
    else
      p 222
    end


    Tracking << tracking_hash
    
    return render :js => ""
  end
end
