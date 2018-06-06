# 广告计划
module Ad
  class Campaign < ApplicationRecord
  	has_many :creatives

    serialize :base_tags
    serialize :pre_tags
    serialize :city
    serialize :products
    
    before_save :set_tags

    has_many :exposure_das
    has_many :click_das
    has_many :event_das

    enum status: {
      isa_initial: 0,   #默认状态
      isa_confirmed: 1, #开启
      isa_stop: 2,  #暂停
      isa_deleted: -1   #关闭
    }

	  def set_tags
	    self.pre_tags = self.pre_tags.to_s.split(" ")
	    self.base_tags = self.base_tags.to_s.split(" ")
	  end

  	# 返回转化追踪的js代码
  	def event_tracking_script(evrnt_no)
      %Q(
       <script type="text/javascript" async>
          document.write(unescape("%3Cscript src='/user_trackings/event_data?evrnt_no=#{evrnt_no}&campaign_id=#{self.id}" + "&opxtitle=" + opxtitle + "&opxurl=" + opxurl + "&opxreferrer=" + opxreferrer + "&opxid=" + opxid + "&opxuserAgent=" + opxuserAgent + "' type='text/javascript'%3E%3C/script%3E"));
       </script>
      )
    end

  	def show_tag
      self.base_tags + self.pre_tags
  	end

    # 宽高匹配最合适的创意
  	def ad_size_match(width,height,ad_type=0)
      match_creatives = self.creatives
      cap_creatives = []
      match_creatives.each do |ad|
      	ad = ad.ad_size
        ad_size = ad.split("*")
        cap_width = ad_size[0].to_i - width.to_i 
        cap_height = ad_size[1].to_i - height.to_i 
        cap_creatives << cap_width.to_i + cap_height.to_i
      end
      cap_index = cap_creatives.index(cap_creatives.min)
      match_creatives[cap_index]
  	end
	 
  end
end