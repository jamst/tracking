# coding: utf-8
# 雇员管理
class Admin::EmployeesController < Admin::BaseController
  # before_action :authenticate_employee!, :except => [:forget_password, :reset_mail]
  # before_action :left_tab, :only => [:index]
  # before_action :set_employee, only: [:destroy]
  def desboart

  end

  def index
    @q = SearchParams.new(params[:search_params] || {})
    @employees = Employee.default_where(@q.attributes(self)).page(params[:page]).per(10)
  end

  def new
    @html_title =  "New employee"
    @employee =  Employee.new
    render :layout => false
  end

  def edit
    @html_title = "Edit employee"
    @employee =  Employee.find(params[:id])
    render :layout => false
  end

  def show
    @html_title =  "Show employee"
    @employee =  Employee.find(params[:id])
    render :layout => false
  end

  def add_roles
    @employee = Employee.find(params[:id])
  end

  def save_roles
    @employee = Employee.find(params[:id])
    @employee.role_ids = params[:employee][:role_ids]
  end

  def update
    @employee = Employee.find(params[:id])

    respond_to do |format|
      if @employee.update_attributes(permitted_resource_params)
        format.json { render :json=>{:success=>true} }
      else
        format.json { render :json=>{:success=>false} }
      end
    end
  end

  def create
    @employee = Employee.new
    @employee.attributes = permitted_resource_params
    if @employee.save
      flash[:success] = flash_message_for(@employee, :successfully_created)
      respond_with(@employee) do |format|
        format.html { redirect_to location_after_save }
        format.js   { render :layout => false }
      end
    else
      respond_with(@employee) do |format|
        format.html do
          flash.now[:error] = @employee.errors.full_messages.join(", ")
          render action: 'new'
        end
        format.js { render layout: false }
      end
    end
  end

  def destroy
    @employee.employee_status = params[:employee_status] if params[:employee_status]
    if @employee.save
      respond_to do |format|
        format.js
      end
    else
      respond_with(@employee) do |format|
        format.html { redirect_to location_after_destroy }
      end
    end
  end

  def location_after_destroy(options = {})
    polymorphic_url([:admin,:employees],options)
  end

  def location_after_save(options = {})
    polymorphic_url([:admin,:employees],options)
  end

  def permitted_resource_params
    params.require(:employee).permit!
  end

  #找回密码
  def forget_password
    return unless request.post?
    userinfo =  params[:email].strip
    employee = Employee.where("name = ? or email = ?", userinfo, userinfo)
    if employee.present? && userinfo.present?
      employee.last.send_user_mail
      redirect_to :action => "reset_mail"
    else
      flash.now[:warning]  = "Please enter the correct user name / registered mail"
    end
  end

  # 邮件重置
  def reset_mail

  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end


end
