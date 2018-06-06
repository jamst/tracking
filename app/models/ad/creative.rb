# 广告创意
module Ad
  class Creative < ApplicationRecord

    belongs_to :campaign
    has_many :attachments, as: :attachment_entity
    accepts_nested_attributes_for :attachments, allow_destroy: true

    enum status: {
      isa_initial: 0,   #默认状态
      isa_confirmed: 1, #开启
      isa_finished: 2,  #暂停
      isa_deleted: -1   #关闭
    }

    enum ad_size: {
      "200*200": 0,   
      "250*250": 1, 
      "300*250": 2,  
      "320*250": 3,
      "336*280": 4,
      "468*60": 5,
      "600*90": 6,
      "728*90": 7,
      "950*90": 8,  
      "960*90": 9,
      "1000*90": 10
    }

    enum ad_type: {
      image: 0,   #默认状态图片
      flash: 1  #动画
    }

  end
end