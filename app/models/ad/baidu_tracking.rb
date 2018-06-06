
module Ad
  class BaiduTracking < ApplicationRecord

  	# 每个cookie + 百度唯一链接 的uniq

     def self.load_tracking(load_time=Time.now.yesterday.at_beginning_of_day)
	   # 缓存导入数据库	
	       Ad::UserTracking.where("created_at >= ? and opxurl like '%source=baidu%' ",load_time).each do |message| 
	         tracking = Ad::BaiduTracking.find_by(opxpid:message[:opxpid],opxurl:message[:opxurl]) 
	         if tracking.present? && tracking.disabled != 1
	             tracking.spread_times = tracking.spread_times + 1
               tracking.status = tracking.status + 1 if message[:opxid] > 0 && tracking.status == 0
	             tracking.disabled = 1 if ((Time.now - tracking.time_now).to_f/(60*60*24)).ceil > 14
	             tracking.save
	         else
	           tracking = Ad::BaiduTracking.create(opxpid:message[:opxpid],opxid:message[:opxid],time_now:message[:time_now],domain:message[:domain],
	         	            opxtitle:message[:opxtitle],opxreferrer:message[:opxreferrer],opxurl:message[:opxurl],ip:message[:ip],
	         	            opxuserAgent:message[:opxuserAgent])
	           tracking.spread_times = tracking.spread_times + 1
             tracking.status = tracking.status + 1 if message[:opxid] > 0
	           opxurl_option =  opxurl_analyse(message[:opxurl])
	           tracking.cas = opxurl_option["cas"]
	           tracking.active_id = opxurl_option["active_id"]
	           tracking.keyword = opxurl_option["keyword"]
	           tracking.source = opxurl_option["source"]
	           tracking.plan = opxurl_option["plan"]
	           tracking.unit = opxurl_option["unit"]
	           tracking.ly = opxurl_option["ly"]
	           tracking.e_matchtype = opxurl_option["e_matchtype"]
	           tracking.e_creative = opxurl_option["e_creative"]
	           tracking.e_adposition = opxurl_option["e_adposition"]
	           tracking.e_pagenum = opxurl_option["e_pagenum"]
	           tracking.e_keywordid = opxurl_option["e_keywordid"]
	           tracking.save
	         end    
	       end  
           
         # 客户为百度带来的首次注册转化
	       register_conversion

	       # 客户为百度带来的询盘转化
	       inquiry_conversion

	       # 客户为百度带来的订单转化
	       order_conversion
	 end


   # 客户为百度带来的首次注册转化
	 def self.register_conversion
       Ad::BaiduTracking.where("opxid = 0 and disabled != 1 ").each do |message| 
         user  = User.find_by(opxpid:message.opxpid)
       	 opxid = user.present? ? user.id : Ad::UserTracking.where("opxpid = ? and opxid > 0",message.opxpid).last&.opxid
       	 
       	 if opxid 

       	   user = User.find_by(id:opxid) 
       	   message.opxid = user&.id

       	   unless user.opxpid
       	     user.update(opxpid:message[:opxpid]) 
       	     message.status = message.status + 1

             if message.time_now <= user.created_at
                Ad::ConversionMapping.create(opxpid:message[:opxpid],opxid:message[:opxid],time_now:message[:time_now],domain:message[:domain],
         	                   opxtitle:message[:opxtitle],opxreferrer:message[:opxreferrer],opxurl:message[:opxurl],ip:message[:ip],
         	                   opxuserAgent:message[:opxuserAgent],conversion_times:1,cas:message[:cas],active_id:message[:active_id],
         	                   keyword:message[:keyword],source:message[:source],status:message[:status],tracking_type:"Ad::BaiduTracking",
         	                   tracking_id:message.id,mapping_type:"User",mapping_id:user.id)
                message.status = message.status + 10
             end
           end  

         end

         message.disabled = 1 if ((Time.now - message.time_now).to_f/(60*60*24)).ceil > 14
         message.save

       end
	 end


	 # 客户为百度带来的询盘转化
	 def self.inquiry_conversion
       Ad::BaiduTracking.where("status < 100 and disabled != 1 and opxid > 0 and cas is not null").each do |message| 

       	 chemical = Chemical.find_by(cas:message.cas)

         inquiry = Inquiry.where("user_id = ? and chemical_id = ? and created_at >= ?",message.opxid , chemical.id , message.time_now).last
         if inquiry.present? 
            Ad::ConversionMapping.create(opxpid:message[:opxpid],opxid:message[:opxid],time_now:message[:time_now],domain:message[:domain],
     	                   opxtitle:message[:opxtitle],opxreferrer:message[:opxreferrer],opxurl:message[:opxurl],ip:message[:ip],
     	                   opxuserAgent:message[:opxuserAgent],conversion_times:1,cas:message[:cas],active_id:message[:active_id],
     	                   keyword:message[:keyword],source:message[:source],status:message[:status],tracking_type:"Ad::BaiduTracking",
     	                   tracking_id:message.id,mapping_type:"Inquiry",mapping_id:inquiry.id)
            message.status = message.status + 100
            message.save
         end

       end
	 end



	 # 客户为百度带来的订单转化
	 def self.order_conversion
       Ad::BaiduTracking.where("status < 1000 and disabled != 1 and opxid > 0 and cas is not null").each do |message| 
         chemical = Chemical.find_by(cas:message.cas)
         
         order_detail = OrderDetail.where("user_id = ? and chemical_id = ? and created_at >= ?",message.opxid ,chemical.id , message.time_now).last
         if order_detail.present? 
            Ad::ConversionMapping.create(opxpid:message[:opxpid],opxid:message[:opxid],time_now:message[:time_now],domain:message[:domain],
     	                   opxtitle:message[:opxtitle],opxreferrer:message[:opxreferrer],opxurl:message[:opxurl],ip:message[:ip],
     	                   opxuserAgent:message[:opxuserAgent],conversion_times:1,cas:message[:cas],active_id:message[:active_id],
     	                   keyword:message[:keyword],source:message[:source],status:message[:status],tracking_type:"Ad::BaiduTracking",
     	                   tracking_id:message.id,mapping_type:"OrderDetail",mapping_id:order_detail.id)
            message.status = message.status + 1000
            message.save
         end

       end
	 end


   # 解析百度参数
   # 例子："http://www.whmall.com/products/407-25-0.html?source=baidu&plan=爆品推广&unit=三氟乙酸酐&keyword=三氟乙酸干&ly=PC&e_matchtype=1&e_creative=21057998872&e_adposition=clg1&e_pagenum=1&e_keywordid=81813623744"
	 def self.opxurl_analyse(opxurl)
       result = {}
       option = opxurl.split("/").last
       cas = option.split(".html?").first
       result["cas"] = cas
       options = option.split(".html?").last
       options.split("&").each do |op|
       	  opt = op.split("=")
          result[opt[0]] = opt[1]
       end
       return result
	 end
	 

  end
end

