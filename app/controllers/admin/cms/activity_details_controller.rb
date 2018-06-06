class Admin::Cms::ActivityDetailsController < Admin::BaseController
  before_action :set_activity_detail, only: [:edit, :update, :destroy]

  def index
    @activity = ::Activity.find params[:activity_id]
    @activity_details = @activity.activity_details.default
  end

  def new
    @activity = ::Activity.find params[:activity_id]
    @activity_detail = ActivityDetail.new(activity_id: params[:activity_id])
  end

  def edit
  end

  def create
    @activity_detail = ActivityDetail.create(activity_detail_params)
  end

  def update
    @activity_detail.update(activity_detail_params)
  end

  def destroy
    @activity_detail.update(status: "deleted")
    render 'admin/cms/activity_details/delete'
  end

  private

  def activity_detail_params
    params.require(:activity_detail).permit(:activity_id,
                                            :name,
                                            :chemical_cas,
                                            :packages,
                                            :denomination,
                                            :package_unit

    )
  end


  def set_activity_detail
    @activity_detail = ::ActivityDetail.find params[:id]
  end
end
