module Activities::TestingOrderWelfareMod
  extend ActiveSupport::Concern

  included do
    # 活动触发任务
    after_create :testing_order_welfares_init , if: -> { Activity.find(1).isa_confirmed? && self.amount >= 10000 }
    after_update :cancel_order_welfares , if: -> { Activity.find(1).isa_confirmed? && self.amount < 10000 }
  end

  def testing_order_welfares_init
    Activities::TestingOrderWelfare.create(activity_id:1,user_id:self.user_id,customer_order_id:self.id,expiry_on:Activity.find(1).expiry_on,spread_no:([*('A'..'Z'),*('0'..'9')]-%w(0 1 h I O)).sample(4).join )
  end

  def cancel_order_welfares
    welfare = Activities::TestingOrderWelfare.find_by_customer_order_id(self.id)
    if welfare
      self.class.transaction do	
        welfare.update(status:"isa_deleted") 
        Ticket.where(mod_entity_type:"Activities::TestingOrderWelfare",mod_entity_id:welfare.id,user_id:self.user_id).update(status:"isa_deleted")
      end  
    end
  end

end