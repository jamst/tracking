class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout "application" 


  def update_or_create_opxpid
    unless cookies[:opxPID]
      host_ip = "192.168.0.113:3000".to_s.gsub(/(\.|:)/, '')
      t_format = Time.now.strftime('%Y%m%d%H%M%S%6N')
      randid = "%08d" % (rand*100000000).to_i

      opxpid = "#{t_format}#{host_ip}#{randid}"

      cookies[:opxPID] = opxpid
    end
  end

end
