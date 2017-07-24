module Activeable
  extend ActiveSupport::Concern
  INACTIVE = 0
  ACTIVE = 1
  DELETED = -1
  included do
    enum active: {
	    actived: ACTIVE,
      inactive: INACTIVE,
      deleted: DELETED
    }
  end


  def deleted_it
    self.active = DELETED
    self.save
  end

  def is_ready_to_deleted?
    !deleted?
  end

  def inactive_it
    self.active = INACTIVE
    self.save
  end

  def is_ready_to_inactive?
    actived?
  end

  def active_it

    if self.class.name == 'DirectShipRule'
      sale_goods = SaleGoodsRecommend.find_by(chemical_id: self.chemical_id)
      if sale_goods.present?
        if sale_goods.employee.blank?
          sale_goods.update(status: :status_saled, employee_id: self.vm_id) unless sale_goods.status_saled?
        else
          sale_goods.update(status: :status_saled) unless sale_goods.status_saled?
        end

      end
    end
    self.active = ACTIVE
    self.save
  end

  def is_ready_to_active?
    !actived?
  end
end
