class Admin::SessionsController < Devise::SessionsController
 layout false  
 # before_action :configure_sign_in_params, only: [:create]
  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    resource = warden.authenticate!(scope: resource_name, recall: "#{controller_path}#new")
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    # resource.ensure_private_token!
    respond_to do |format|
      #format.html { redirect_to after_sign_in_path_for(resource) }
      #current_employee.add_log("#{current_employee.email} Login At #{Time.now.format_date(:full)}",request.ip)
      format.html { redirect_to login_jump_url }
      format.json { render status: '201', json: resource.as_json(only: [:login, :email, :private_token]) }
    end
  end

  # DELETE /resource/sign_out
  def destroy
    Rails.cache.delete("current_employee_#{current_employee.id}".to_sym)
    sign_out
    redirect_to temporary_reports_path
    #super
  end

  # 登录后不同角色跳转
  def login_jump_url
   temporary_reports_path
  end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end

end
