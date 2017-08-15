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
    Rails.cache.fetch(tag)
  end

  # 删除缓存
  def delete_cache
    Rails.cache.read("uuids_list").each do |uuid|
      Rails.cache.delete("#{uuid}_url_list")
      Rails.cache.delete("#{uuid}_uuids")
      Rails.cache.delete(uuid)
      Rails.cache.delete("#{uuid}_message")
      Rails.cache.delete("#{uuid}_tags")
      TRACKING_TAG.keys.each do |_|
        Rails.cache.delete(_)
        Rails.cache.delete("#{_}_uuids") 
        Rails.cache.delete("#{uuid}_#{_}")
      end
    end
    Rails.cache.delete("uuids_list")
    Rails.cache.delete("uuids")
  end

  # 定义成可配置
  TRACKING_TAG = {"temporary_reports"=>"报表","temporary_reports/report"=>"报表查看"}


