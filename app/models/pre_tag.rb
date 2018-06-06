class PreTag < ApplicationRecord

  enum status: {
    isa_initial: 0,   #未使用默认状态
    isa_confirmed: 1, #激活状态
    isa_finished: 2,  #经常使用
    isa_deleted: -1   #关闭
  }

  default_scope -> { where('pre_tags.status != -1') }
  has_many :my_tags, as: :tag_entity
  
end