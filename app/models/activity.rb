class Activity < ApplicationRecord
  belongs_to :category_type, class_name: 'ActivityCategory', foreign_key: 'category'
  belongs_to :employee, class_name: 'Employee', foreign_key: 'initiator'
  has_many :activity_details

  enum status: {
    isa_initial: 0,   #默认状态
    isa_confirmed: 1, #开启
    isa_finished: 2,  #完结
    isa_deleted: -1   #删除
  }

  enum effect: {
      achieve: 1,     #达到预期
      not_achieve: 0  #没有达到预期
  }


  serialize :base_tags
  serialize :tags

  before_save :set_tags

  def set_tags
    self.tags = self.tags.to_s.split(" ")
    self.base_tags = self.base_tags.to_s.split(" ")
    self.activity_mod = self.category_type&.name_mod
  end

  def self.aout_activity_status
    Activity.where.not(status: :isa_deleted).each do |a|
       a.update(status: :isa_confirmed) if a.start_time <= Time.now && a.expiry_on > Time.now && !a.isa_confirmed?
       a.update(status: :isa_finished) if (a.start_time > Time.now || a.expiry_on <= Time.now) && !a.isa_finished?
    end
  end
  
end