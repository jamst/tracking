module Activities::JdticketWelfareMod
  extend ActiveSupport::Concern

  included do
    # 活动触发任务
    after_create :jdticket_welfare_init
    after_update :cancel_jdticket_welfare, if: -> { self.detail_status == 7 && Activities::JdticketWelfare.find_by_order_detail_id(self.id) }
  end
  
  # 采购订单创建触发
  def jdticket_welfare_init
    Activity.isa_confirmed.where(category:2).each do |activity|
      activity.activity_details.where(chemical_id:self.chemical_id).each do |activity_detail|
        order_package = self.sum_package
        # 如果单位不一致转化单位
        order_package = convert_unit(order_package, self.package_unit, activity_detail.package_unit, 1)  if activity_detail.package_unit != self.package_unit
        denomination,live = activity_detail.match_package(order_package.to_f)
        if denomination.present?
          live_package = "#{live.match(/[1-9]\d*/).to_s}#{activity_detail.package_unit}"
          Activities::JdticketWelfare.create(activity_id:activity.id,
            activity_detail_id: activity_detail.id,
            user_id:self.customer_order.user_id,
            order_detail_id:self.id,
            denomination: denomination,
            expiry_on:activity.expiry_on,
            live_package:live_package  )
        end
      end
    end
  end

  # 采购订单取消触发
  def cancel_jdticket_welfare
    welfare.update(status:"isa_deleted") 
    Ticket.where(mod_entity_type:"Activities::JdticketWelfare",mod_entity_id:welfare.id,user_id:self.user_id).update(status:"isa_deleted")
  end

end