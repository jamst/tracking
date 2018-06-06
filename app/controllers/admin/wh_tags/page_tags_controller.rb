class Admin::WhTags::PageTagsController < Admin::BaseController

  before_action :set_page_tag, only: [:show, :edit, :update, :destroy]	

  def index
  	@q = SearchParams.new(params[:search_params])
    search_params = @q.attributes(self)
    @page_tags =  PageTag.default_where(search_params).order(id: :desc).page(params[:page]).per(10)
  end

  def new
    @page_tag = PageTag.new
  end

  def edit

  end

  def create
    @page_tag = PageTag.create(page_params)
  end

  def update
    @page_tag.update(page_params)
  end

  def destroy
    @page_tag.update(status:-1)
  end

  def show
  	@base_tag = BaseTag.find_by(name:@page_tag.name)
    @base_users = @base_tag.my_tags
    @pre_tag = PreTag.find_by(name:@page_tag.name)
    @pre_users = @pre_tag.my_tags
  end

  private

  def set_page_tag
    @page_tag = PageTag.find(params[:id])
  end

  def page_params
    params.require(:page_tag).permit(:name,
                                     :parent_id,
                                     :page_type,
                                     :status,
                                     :base_name,
                                     :page_url,
                                     :status
    )
  end




end