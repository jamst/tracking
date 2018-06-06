class Admin::Cms::JdTicketsController < Admin::BaseController

  def index
    @q = SearchParams.new(params[:search_params])
    search_params = @q.attributes(self)
    @jd_tickets = Activities::JdTicket.default_where(search_params).page(params[:page]).per(10)
  end

  # 导入京东卷页面
  def import_jd_tickets
  end

  def import_error(msg)
    flash[:msg] = msg
    redirect_to action: :index
  end

  # 活动匹配核发京东券
  def mapping_ticket
    Activities::JdticketWelfare.payfor_tickets(params[:activity_id])
  end

  # 京东券活动明细
  def jd_activity_details
    @q = SearchParams.new(params[:search_params] || {activity_id: params[:activity_id]})
    search_params = @q.attributes(self)

    if params[:activity_id].present?
      @activity = Activity.find(params[:activity_id])
    elsif params[:search_params][:activity_id].present?
      @activity = Activity.find(params[:search_params][:activity_id])
    else
      @activity = nil
    end

    if @activity
      @jdticket_welfares = Activities::JdticketWelfare.where(activity_id: @activity.id).includes(:order_detail, :activity, [user: :company]).default_where(search_params)
    else
      @jdticket_welfares = Activities::JdticketWelfare.includes(:order_detail, :activity, [user: :company]).default_where(search_params)
    end

    @wait_payment = @jdticket_welfares.left_joins(:order_detail).where("jdticket_welfares.status in (?) and ( order_details.ship_status = 2 || order_details.payment_status = 1)", [0, 1]).group_by(&:denomination)
    @jd_tickets = Activities::JdTicket.unissued.group_by(&:denomination)

    @jdticket_welfares = @jdticket_welfares.page(params[:page]).per(10)

  end

  # 导入京东券数据
  def create_import_jd_tickets
    time1 = Time.now
    file = params[:attachment][:path]
    #校验文件格式
    import_error("失败，文件格式不正确，请上传.xlsx格式的文件。") and return unless check_file?(file)
    book = Roo::Spreadsheet.open file
    sheet = book.sheet 0

    result_book = Spreadsheet::Workbook.new
    result_sheet = result_book.create_worksheet
    _file_ok = true

      row_num = 0
      error_row = 0
      row_msg = []
      sheet.each_with_index do |row, index|

        @jdticket = _jdticket = Activities::JdTicket.new()
        if index > 0
          jdticket = Activities::JdTicket.find_by(card_id: row[2])
          if jdticket.present?
            row_msg[error_row] = index
            row_num += 1
            error_row += 1
            next
          else
            _jdticket.category = row[0]
            _jdticket.denomination = row[1]
            _jdticket.card_id = row[2]
            _jdticket.card_password = row[3]
            _jdticket.expiry_on = row[4].split("-",).last.gsub(/[\u4e00-\u9fa5]/, '-').to_date
            _jdticket.save
            row_num += 1
          end
        end
      end
      if error_row == 0
        flash[:notice] = "共有" + row_num.to_s + "行，全部导入成功!"
      else
        flash[:success] = "共有" + row_num.to_s + "行，导入成功" + (row_num-error_row).to_s + "行。第" + row_msg.join(",") + "行导入失败,请检查是否已导入。"
      end
    @jd_tickets =  Activities::JdTicket.where(created_at: time1).page(params[:page]).per(10)
    render template: "admin/cms/jd_tickets/index", :locals => { :jd_ticket => @jd_tickets }
  end


  def check_file?(file)
    return false if file.blank?
    file.original_filename =~ /xlsx$/
  end
end