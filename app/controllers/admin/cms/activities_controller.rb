class Admin::Cms::ActivitiesController < Admin::BaseController
  before_action :set_activity, only: [:edit, :update, :destroy]

  def index
    @activities = ::Activity.where.not(status: :isa_deleted).order(id: :desc).page(params[:page]).per(10)
  end

  def new
    @activity = ::Activity.new
  end

  def edit
  end

  def create
    @activity = ::Activity.create(activity_params)
  end

  def update
    @activity.update(activity_params)
  end

  def destroy
    @activity.update(status: "isa_deleted")
    flash[:success] = "删除成功"
    redirect_to admin_cms_activities_path
  end

  def levels_show_array
    if @field == 'rebate_rules'
      arr = rules[:levels].to_s.split(',')
      arr.map do |p|
        package = p.split('~')
        "#{package[0]}元<=x" + (package[1].blank? ? '' : "< #{package[1]}元" )
      end
    else
      if rules[:package_type].to_i == 0
        arr = rules[:levels].to_s.split(',')
        arr.map do |p|
          package = p.split('~')
          "#{package[0]}#{@price.package_unit}<=x" + (package[1].blank? ? '' : "<#{package[1]}#{@price.package_unit}" )
        end
      else
        rules[:levels].to_s.split(',').map{|p| "#{p}#{@price.package_unit}"}
      end
    end
  end

  def get_cost_price(package)
    packages = ""
    denomination = ""


    return packages,denomination
  end

  private
  def activity_params
    params.require(:activity).permit(:name,
                                     :category,
                                     :activity_mod,
                                     :status,
                                     :base_tags,
                                     :tags,
                                     :describe,
                                     :summary,
                                     :initiator,
                                     :expected_cost,
                                     :actual_cost,
                                     :effect,
                                     :expiry_on,
                                     :start_time,
    )
  end

  def activity_detail_params
    params.require(:activities_activity_detail).permit(:activity_id,
                                            :name,
                                            :chemical_id,
                                            :package,
                                            :package_unit

    )
  end


  def set_activity
    @activity = ::Activity.find params[:id]
  end
end
