class Admin::Ad::CreativesController < Admin::BaseController

  before_action :set_creative, only: [:show, :edit, :update, :destroy]	
  before_action :set_campaign, only: [:new, :show, :edit, :destroy]  

  def index
  	@q = SearchParams.new(params[:search_params])
    search_params = @q.attributes(self)
    @campaign_id = search_params["campaign.name"].present? ? ::Ad::Campaign.find_by(name:search_params["campaign.name"])&.id : params[:campaign_id]
    search_params[:campaign_id] = @campaign_id
    @campaign = ::Ad::Campaign.find(@campaign_id)
    @creatives =  ::Ad::Creative.default_where(search_params).order(id: :desc).page(params[:page]).per(10)
  end

  def new
    @creative = ::Ad::Creative.new
    @attachment = @creative.attachments.last || @creative.attachments.new
  end

  def edit
    @attachments = @creative.attachments
  end

  def create
    @creative = ::Ad::Creative.create(creative_params)
    @campaign = @creative.campaign
  end

  def update
    @creative.update(creative_params)
    @campaign = @creative.campaign
  end

  def destroy
    @creative.update(status:-1)
  end

  def show

  end

  private

  def set_creative
    @creative = ::Ad::Creative.find(params[:id])
  end

  def set_campaign
    @campaign = ::Ad::Campaign.find(params[:campaign_id])
  end

  def creative_params
    p = params.require(:ad_creative).permit(:name,
                                     :campaign_id,
                                     :ad_size,
                                     :link,
                                     :status,
                                     attachments_attributes: [:path]
    )

    p[:link] = "http://#{p[:link]}" if p[:link].present? && p[:link] !~ /^http/
    p

  end

end