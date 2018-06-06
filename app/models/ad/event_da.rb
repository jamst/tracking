# 广告转化
module Ad
  class EventDa < ApplicationRecord

  	def self.load_tracking
      cache_read("user_uuids_list").each do |_| 
        messages = cache_read("#{_}_event_url_list")
	      messages.each do |message|
          if message
             Ad::EventDa.create(opxpid:_,opxid:message[:opxid],time_now:message[:time_now],domain:message[:domain],
                                 opxtitle:message[:opxtitle],opxreferrer:message[:opxreferrer],opxurl:message[:opxurl],ip:message[:ip],
                                 opxuserAgent:message[:opxuserAgent],campaign_id:message[:campaign_id],creative_id:message[:creative_id],event_no:message[:event_no]) 
          end
        end  if messages
	      Rails.cache.delete("#{_}_event_url_list")
      end if cache_read("user_uuids_list").present?
  	end

  end
end