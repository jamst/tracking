module Activities
  class TrackingAnalyse
   
    # 标记员工处理业务相关度
    def self.taging_tracking_cache
      @uuids = cache_read("uuids_list")||[]	
      uuids_sizes = []
      @uuids.each do |uuid|
      	em = Employee.find_by(id:cache_read(uuid).to_i) if cache_read(uuid).to_i > 0 
        if em
        	uuids_sizes << cache_read("#{uuid}_uuids") 
        	valid_keys = cache_read("#{uuid}_tags")
          @tags = TRACKING_TAG.slice(*valid_keys).values.to_s
          @tags.delete("[").delete("]").delete("\"").split(",").each do |tag|
            base_tag = BaseTag.find_or_create_by(name:tag.strip)
            mt = MyTag.find_or_create_by(mod_entity_type:"Employee",mod_entity_id:em&.id,tag_entity_type:"BaseTag",tag_entity_id:base_tag.id)
            mt.spread_times = mt.spread_times + 1
            mt.save 
          end
        end
      end
      uuid = @uuids[uuids_sizes.index(uuids_sizes.max)]
      em = Employee.find_by(id:cache_read(uuid).to_i) if cache_read(uuid).to_i > 0 
      # 单日访问量最大uuid
      if em
        base_tag = BaseTag.find_or_create_by(name: "后台单日访问最大量")
        mt = MyTag.find_or_create_by(mod_entity_type:"Employee",mod_entity_id:em&.id,tag_entity_type:"BaseTag",tag_entity_id:base_tag.id)
        mt.spread_times = mt.spread_times + 1
        mt.save 
      end
      
      page_user_tracking_cache
    end  


    # 标记用户页面处理业务相关度
    def self.page_user_tracking_cache
      user_tracking_tag = PageTag.where(base_name:"页面标签",page_type:"前台客户").inject({}){|o,j| o[j.page_url] = j.name ; o }
      user_tracking_pre_tag = PageTag.where("base_name != '页面标签' and page_type = '前台客户' ").inject({}){|o,j| o[j.page_url] = j.name ; o }

      @uuids = cache_read("user_uuids_list")||[] 
      uuids_sizes = []
      @uuids.each do |uuid|
        em = User.find_by(id: cache_read(uuid).to_i ) if cache_read(uuid).to_i > 0 
        if em
          uuids_sizes << cache_read("#{uuid}_user_uuids") 
          valid_keys = cache_read("#{uuid}_user_tags")

          # 标记用户页面处理业务相关度
          @tags = user_tracking_tag.slice(*valid_keys).values.to_s
          @tags.delete("[").delete("]").delete("\"").split(",").each do |tag|
            base_tag = BaseTag.find_or_create_by(name:tag.strip)
            mt = MyTag.find_or_create_by(mod_entity_type:"User",mod_entity_id:em&.id,tag_entity_type:"BaseTag",tag_entity_id:base_tag.id)
            mt.spread_times = mt.spread_times + 1
            mt.save 
          end

          # 标记用户额外处理业务相关度
          @pre_tags = user_tracking_pre_tag.slice(*valid_keys).values.to_s
          @pre_tags.delete("[").delete("]").delete("\"").split(",").each do |tag|
            pre_tag = PreTag.find_or_create_by(name:tag.strip)
            mt = MyTag.find_or_create_by(mod_entity_type:"User",mod_entity_id:em&.id,tag_entity_type:"PreTag",tag_entity_id:pre_tag.id)
            mt.spread_times = mt.spread_times + 1
            mt.save 
          end

        end
      end
      uuid = @uuids[uuids_sizes.index(uuids_sizes.max)]
      em = User.find_by(id: cache_read(uuid).to_i ) if cache_read(uuid).to_i > 0 
      # 单日访问量最大uuid
      if em
        base_tag = BaseTag.find_or_create_by(name: "客户单日访问最大量")
        mt = MyTag.find_or_create_by(mod_entity_type:"User",mod_entity_id:em&.id,tag_entity_type:"BaseTag",tag_entity_id:base_tag.id)
        mt.spread_times = mt.spread_times + 1
        mt.save 
      end
    end

  end
end
