class MyTag < ApplicationRecord
  belongs_to :mod_entity, polymorphic: true
  belongs_to :tag_entity, polymorphic: true

  # 显示标签名字
  def show_tag
    self.tag_entity.name
  end

  # 活动标签同步
  def self.init_tag_mapping
    Activity.isa_confirmed.each do |act|
       user_ids = act.activity_mod.constantize.where("created_at >= ?",Time.now.at_beginning_of_day).map(&:user_id)
       user_ids.each do |user_id|

         act.base_tags.each do |btname|
         	 base_tag = BaseTag.find_or_create_by(name: btname)
         	 base_tag.relation_tags = [] if !base_tag.relation_tags.present?
  	       base_tag.relation_tags = (base_tag.relation_tags + act.tags).uniq
  	       base_tag.save
           mt = MyTag.find_or_create_by(mod_entity_type:"User",mod_entity_id:user_id,tag_entity_type:"BaseTag",tag_entity_id:base_tag.id)
           mt.spread_times = mt.spread_times + 1
           mt.save 
         end

         act.tags.each do |tagname|
           pr = PreTag.find_or_create_by(name: tagname)
           mt = MyTag.find_or_create_by(mod_entity_type:"User",mod_entity_id:user_id,tag_entity_type:"PreTag",tag_entity_id:pr.id)
           mt.spread_times = mt.spread_times + 1
           mt.save
         end

       end
    end 
  end   

  # 符合特定tags的人有哪些
  def same_tags_persions(tags)
    user_ids = MyTag.where(tag_entity_type:'PreTag',tag_entity_id: persion_pre_tag_ids,mod_entity_type:"User").map(&:mod_entity_id).uniq 
  end

  # 与某人最相似的人有哪些
  def same_persion(persion_id)
    persion_pre_tag_ids =  persion_pre_tags(persion_id)
    persion_base_tag_ids = persion_base_tags(persion_id)

    same_pre_persion = {}
    same_base_persion = {}
    all_same = {}

    pre_tags = MyTag.select("count(mod_entity_id) as count_size ,mod_entity_id").where(tag_entity_type:'PreTag',tag_entity_id: persion_pre_tag_ids,mod_entity_type:"User" ).group(&:mod_entity_id)

    base_tags = MyTag.select("count(mod_entity_id) as count_size ,mod_entity_id").where(tag_entity_type:'BaseTag',tag_entity_id: persion_base_tag_ids,mod_entity_type:"User" ).group(&:mod_entity_id)

    pre_tags.each do |pre|
      # 8<=x<15个tags的人视为一致的人
      if pre["count_size"].to_f >=8 && pre["count_size"].to_f < 15
        same_pre_persion[pre["mod_entity_id"]] << pre["count_size"].to_f * 100 / persion_pre_tag_ids.size
        change_pre_tag_each_other(tag_type,persion_id,pre["mod_entity_id"])
      end
    end

    base_tags.each do |base|
      # 5<=x<10个tags的人视为一致的人
      if base["count_size"].to_f >=5 && base["count_size"].to_f < 10
        same_base_persion[base["mod_entity_id"]] << base["count_size"].to_f * 100 / persion_base_tag_ids.size 
        change_base_tag_each_other(tag_type,persion_id,base["mod_entity_id"])
      end
    end

    all_same_keys = (same_pre_persion.keys + same_base_persion.keys).uniq
    both_same_keys = same_pre_persion.keys & same_base_persion.keys

    all_same_keys.each do |k|
      all_same[k] =  both_same_keys.include? k ? same_pre_persion[k].to_f * 0.5 + same_base_persion.to_f * 0.5 : same_pre_persion[k].to_f * 0.8 + same_base_persion.to_f  * 0.8
    end

    return all_same

  end

  # 某人的所有base标签
  def persion_base_tags(persion_id)
    MyTag.where(tag_entity_type:'BaseTag',mod_entity_type:"User",mod_entity_id:persion_id).map(&:tag_entity_id)
  end

  # 某人的所有pre标签
  def persion_pre_tags(persion_id)
    MyTag.where(tag_entity_type:'PreTag',mod_entity_type:"User",mod_entity_id:persion_id).map(&:tag_entity_id)
  end

  # 两个人交换pre标签
  def change_pre_tag_each_other(tag_type,a_user_id,b_user_id)
    all_tags = (persion_pre_tags(a_user_id) + persion_pre_tags(b_user_id)).uniq
    a_add_tags = all_tags - persion_pre_tags(a_user_id)
    a_add_tags.each do |a|
      MyTag.create(mod_entity_type:"User",mod_entity_id:a_user_id,tag_entity_type:"PreTag",tag_entity_id:a,category:2)
    end
    b_add_tags = all_tags - persion_pre_tags(b_user_id)
    b_add_tags.each do |a|
      MyTag.create(mod_entity_type:"User",mod_entity_id:b_user_id,tag_entity_type:"PreTag",tag_entity_id:a,category:2)
    end
  end

  # 两个人交换base标签
  def change_base_tag_each_other(tag_type,a_user_id,b_user_id)
    all_tags = (persion_base_tags(a_user_id) + persion_base_tags(b_user_id)).uniq
    a_add_tags = all_tags - persion_base_tags(a_user_id)
    a_add_tags.each do |a|
      MyTag.create(mod_entity_type:"User",mod_entity_id:a_user_id,tag_entity_type:"BaseTag",tag_entity_id:a,category:2)
    end
    b_add_tags = all_tags - persion_base_tags(b_user_id)
    b_add_tags.each do |a|
      MyTag.create(mod_entity_type:"User",mod_entity_id:b_user_id,tag_entity_type:"BaseTag",tag_entity_id:a,category:2)
    end
  end

  # 两个pre标签合并
  def binding_pre_tag(from_tag_id,to_tag_id)
    from_tags = MyTag.where("tag_entity_type = 'PreTag' and tag_entity_id = ? ",from_tag_id).map(&:mod_entity_id)
    from_tags.each do |user_id|
      MyTag.create(mod_entity_type:"User",mod_entity_id:user_id,tag_entity_type:"PreTag",tag_entity_id:to_tag_id,category:1) unless MyTag.find_by(mod_entity_type:"User",mod_entity_id:user_id,tag_entity_type:"PreTag",tag_entity_id:to_tag_id)
    end
    PreTag.find(from_tag_id).update(status: :isa_deleted)
  end

  # 根据人属性＋大小匹配合适广告
  # todo 匹配方式／产品／地域过滤/ad_type类型
  def self.match_ad(options)
    opxid = options[:opxid]
    tags = MyTag.where(mod_entity_type:"User",mod_entity_id:opxid).map(&:show_tag)

    match_sizes = []

    all_campagins =  Ad::Campaign.isa_confirmed

    all_campagins.each do |camp|
       match_sizes << (camp.show_tag & tags).size 
    end

    # 匹配最多tags广告
    match_max = match_sizes.max

    if match_max.present?  && match_max == 0
      match_campaign_index = match_sizes.index(match_max)

      match_campaign = all_campagins[match_campaign_index]
    else
      match_campaign = all_campagins.sample
    end

    if match_campaign.present?

      # ad_size尺寸
      creative = match_campaign.ad_size_match(options[:height],options[:width],0)

      link = creative.link

      src = creative.attachments&.sample&.attachment_path

      return link,src,creative.campaign_id,creative.id
    else
      return "http://www.whmall.com/products/24424-99-5.html","http://www.whmall.com/uploads/banner/image/00/00/00/50223f42-e3eb-4111-b8da-5063f6d2cfea.jpg",1,1
    end
  end

end