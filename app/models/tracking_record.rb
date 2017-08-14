class TrackingRecord < ApplicationRecord

 def self.load_tracking
   # 缓存导入数据库	
   TrackingRecord.transaction do
       cache_read("uuids_list").each do |_| 
         message = cache_read("#{_}_message")	
         TrackingRecord.create(opxpid:_,opxid:message[:opxid],time_now:message[:time_now],domain:message[:domain],
         	                   opxtitle:message[:opxtitle],opxreferrer:message[:opxreferrer],opxurl:message[:opxurl],ip:message[:ip],
         	                   opxuserAgent:message[:opxuserAgent])
       end	
	   cache_read("uuids_list").each do |_|
	      cache_read("#{_}_url_list").each do |url|
	        TrackingDetail.create(opxpid:_,opxurl:url)
	      end
	   end
   end
   # 清除缓存
   delete_cache
 end

end
