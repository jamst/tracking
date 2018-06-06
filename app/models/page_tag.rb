class PageTag < ApplicationRecord

  enum status: {
    isa_actived: 1, #激活状态
    isa_deleted: -1   #关闭
  }

  def parent
    self.parent_id ? PageTag.find_by(id:self.parent_id) : self
  end

  def parents
    PageTag.where("parent_id is null")
  end
  
end