module Ad
  class UserTracking < ApplicationRecord

     def self.load_tracking
	   # 缓存导入数据库	
	   Ad::UserTracking.transaction do
	       cache_read("user_uuids_list").each do |_| 
	         messages = cache_read("#{_}_user_url_list")	
	         messages.each do |message|
	         	if message
	              Ad::UserTracking.create(opxpid:_,opxid:message[:opxid],time_now:message[:time_now],domain:message[:domain],
	         	                   opxtitle:message[:opxtitle],opxreferrer:message[:opxreferrer],opxurl:message[:opxurl],ip:message[:ip],
	         	                   opxuserAgent:message[:opxuserAgent]) 
	              
	              audience = Ad::Audience.find_or_create_by(opxpid:_)
		          gid_count = audience.gid_count.to_i + 1
		          targeting_ips = audience.targeting_ips.present? ?  audience.targeting_ips.to_a  :  []   
		          targeting_ips = (targeting_ips << message[:ip]).uniq
		          audience.opxid = message[:opxid] if message[:opxid].present?
		          audience.gid_count = gid_count
		          audience.targeting_ips = targeting_ips
		          audience.save!

		        end  
	         end if messages
	       end	if cache_read("user_uuids_list").present?
	   end
	   # 清除缓存
	   delete_user_cache
	 end

     # 每个月集体更新一下user的opxpid (放在百度转化等之后的时间中执行，确保百度的优先转化)
	 def self.month_mapping_user_id(load_time=Time.now.yesterday.at_beginning_of_month)
       Ad::UserTracking.where("created_at >= ? and opxid > 0",load_time).map{|track| [track.opxid,track.opxpid] }&.uniq.each do |tra| 
          user = User.find_by(id:tra[0])
          user.update(opxpid:tra[1])
       end
	 end

     # 清除缓存
	 def self.delete_user_cache
	 	user_tracking_tag = PageTag.where.not(page_type:"后台客户").inject({}){|o,j| o[j.page_url] = j.name ; o }

	    Rails.cache.read("user_uuids_list").each do |uuid|
	      Rails.cache.delete("#{uuid}_user_url_list")
	      Rails.cache.delete("#{uuid}_user_uuids")
	      Rails.cache.delete(uuid)
	      Rails.cache.delete("#{uuid}_user_message")
	      Rails.cache.delete("#{uuid}_user_tags")
	      user_tracking_tag.keys.each do |_|
	        Rails.cache.delete(_)
	        Rails.cache.delete("#{_}_user_uuids")
	      end
	    end
	    Rails.cache.delete("user_uuids_list")
	    Rails.cache.delete("user_uuids")
	end

	 
  end
end



