class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_employee!
  before_action :set_cookie

  def set_cookie
  	unless cookies[:uuid]
      cookies[:uuid] = "11111111"
    end
  end

end
