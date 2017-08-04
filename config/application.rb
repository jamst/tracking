require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PreReport
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.active_record.default_timezone = :local
    config.time_zone = 'Beijing'
    config.i18n.default_locale = :zh
    config.autoload_paths += Dir["#{config.root}/lib"]
  end
end


# 缓存汇总
  def cache_sum(tag)
    if Rails.cache.read(tag).blank? 
        Rails.cache.write(tag, 1)
    else
      tags = Rails.cache.read(tag)
      Rails.cache.write(tag, tags + 1)
    end
  end

  # 缓存储值对
  def cache_value(tag,value)
    Rails.cache.write(tag, value)
  end

  # 缓存数组
  def cache_array(tag,arr,uniq=nil)
    if Rails.cache.read(tag).blank? 
      Rails.cache.write(tag, [arr])
    else
      tags = Rails.cache.read(tag)
      unless uniq && (tags.include? arr)
        tags << arr
        Rails.cache.write(tag, tags) 
      end
    end
  end

  # 读缓存
  def cache_read(tag)
    Rails.cache.fetch(tag)||[]
  end


  TRACKING_TAG = {"dashboard":"首页","crm/companies":"公司管理","inquiry/inquiries":"询盘","inquiry/inquiries/":"报价","order/details":"订单","finance/reconciliations":"财务"}