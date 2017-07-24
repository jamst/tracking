class TrackingsController < ActionController::Base
  # js请求	
  def index
  	#p CGI.unescape(params[:opxcookie]) 

  	tracking_hash = {}
  	tracking_hash[:rnum] = params[:rnum]
    tracking_hash[:time_now] = Time.now
    tracking_hash[:domain] = params[:domain] 
    tracking_hash[:opxtitle] = params[:opxtitle] 
    tracking_hash[:opxreferrer] = params[:opxreferrer] 
    tracking_hash[:opxurl] = params[:opxurl] 
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
    p "22"*100
       p tracking_hash[:opxcookie]
    p "11"*100
    p tracking_hash[:opxuserAgent]

    # 实时处理
      
      # 平台粒度
      # 客户粒度
      # 员工粒度  

    # 日志处理
    render :json => "32132"

  end
end
