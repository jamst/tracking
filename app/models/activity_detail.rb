class ActivityDetail < ApplicationRecord
  include Package

  has_many :jdticket_welfares
  belongs_to :activity
  belongs_to :chemical

  enum status: {
      default: 0,
      deleted: 1
  }

  # 匹配卡密范围
  def match_package(base_package)
    hash_package = hash_rules
    @packages = hash_package[:packages]
    min = @packages.split(',').map{|_|_.match(/[1-9]\d*/).to_s.to_f}.sort.first
    if base_package >= min
      price,live = get_cost_price(base_package)
    else
      price,live = nil,nil
    end
    return price,live 
  end

  def hash_rules
    @hash_rules ||= self.package.nil? ? {} : eval(self.package)
    @hash_rules 
  end


  def denomination
    hash_rules[:denomination] || ''
  end
  def denomination=(value)
    hash_rules[:denomination] = value.gsub('，',',')
    self.package = hash_rules.to_s
  end

  def chemical_cas
    self.chemical_id ? Chemical.find(self.chemical_id).cas : ''
  end
  def chemical_cas=(value)
    self.chemical_id = Chemical.find_by_cas(value)&.id
  end


  def packages
    hash_rules[:packages] || ''
  end
  def packages=(value)
    hash_rules[:packages] = value.to_s.gsub('，',',').strip
    self.package = hash_rules.to_s
  end


  def prices_show_array
    hash_rules[:denomination].split(',') || []
  end


  def levels_array
    arr = hash_rules[:packages].split(',')
     arr.map do |p|
       package = p.split('x')
       if package[0] == ""
         "x #{package[1]}"
       else
         "#{package[0]} " + (package[1].blank? ? 'x' : "x && x #{package[1]}" )
       end
    end
  end

  def levels_array_for_show
    arr = hash_rules[:packages].split(',')
  end


  def find_cost_prices
      return_cose_price = []
      levels_array.each_with_index do |l,i|
        return_cose_price << [l,self.prices_show_array[i]]
      end
      return return_cose_price
  end


  def get_cost_price(package)
    cose_price = nil
    live_cost = ""
    find_cost_prices.each do |live|
      x = package
      if eval(live[0])
        cose_price = live[1].to_f
        live_cost = live[0]
        break
      end
    end
    return cose_price,live_cost
  end
  
end