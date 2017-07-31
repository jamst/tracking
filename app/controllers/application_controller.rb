class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_employee!
  before_action :update_or_create_opxpid


  def update_or_create_opxpid
  	begin
      @cookie_domain = request.env["HTTP_X_DOMAIN_FOR"].to_s.strip unless request.env["HTTP_X_DOMAIN_FOR"].to_s.strip == ""
    rescue
    ensure
      @cookie_domain = ".whmall.test" unless @cookie_domain
    end

    if cookies[:opxPID].to_i > 2000
      opxpid = cookies[:opxPID].to_i.to_s
      cookies[:opxPID] = {
        :value => "",
        :expires => Time.now
      }
      cookies[:opxPID] = {
        :value => opxpid,
        :expires => 2.years.from_now,
        :domain => @cookie_domain
      }
    else
      host_ip = request.env['SERVER_NAME'].to_s.gsub(/(\.|:)/, '')

      t_format = Time.now.strftime('%Y%m%d%H%M%S%6N')
      randid = "%08d" % (rand*100000000).to_i

      opxpid = "#{t_format}#{host_ip}#{randid}"

      cookies[:opxPID] = {
        :value => opxpid,
        :expires => 2.years.from_now,
        :domain => @cookie_domain
      }
    end
    return opxpid
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
  def cache_array(tag,arr=nil)
    if Rails.cache.read(tag).blank? 
      Rails.cache.write(tag, [arr])
    else
      tags = Rails.cache.read(tag)
      tags << arr
      Rails.cache.write(tag, tags) 
    end
  end

  # 读缓存
  def cache_read(tag)
    Rails.cache.fetch(tag)
  end


end
