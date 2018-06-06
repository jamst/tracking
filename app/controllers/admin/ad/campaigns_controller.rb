class Admin::Ad::CampaignsController < Admin::BaseController

  before_action :set_campaign, only: [:show, :edit, :update, :destroy, :event_data_script,:save_event_data,:get_event_data_script]	

  def index
  	@q = SearchParams.new(params[:search_params])
    search_params = @q.attributes(self)
    @campaigns =  ::Ad::Campaign.default_where(search_params).order(id: :desc).page(params[:page]).per(10)
  end

  def new
    @campaign = ::Ad::Campaign.new
  end

  def edit

  end

  def create
    @campaign = ::Ad::Campaign.create(campaign_params)
  end

  def update
    @campaign.update(campaign_params)
  end

  def destroy
    @campaign.update(status:-1)
  end

  def show

  end

  # 设置获取转化代码节点
  def event_data_script

  end
  def save_event_data
    @campaign.update(params_event)
  end
  def get_event_data_script
    @event_no = params[:event_no]
  end

  private

  def set_campaign
    @campaign = ::Ad::Campaign.find(params[:id])
  end

  def campaign_params
    params.require(:ad_campaign).permit(:name,
                                     :activity_id,
                                     :client_id,
                                     :status,
                                     :base_tags,
                                     :pre_tags,
                                     :products,
                                     :city,
                                     :start_time,
                                     :end_time,
                                     :describe,
                                     :expected_cost
    )
  end

  def params_event
    params.require(:ad_campaign).permit(:event_1,
                                        :event_2,
                                        :event_3,
                                        :event_4,
                                        :event_5,
                                        :event_6
    )
  end

end