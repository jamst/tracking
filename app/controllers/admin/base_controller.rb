class Admin::BaseController < ActionController::Base
    protect_from_forgery with: :exception
    layout false 
    respond_to :html
    before_action :authenticate_employee!
    before_action :update_or_create_opxpid
end
