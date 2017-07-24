class TemporaryReportsController < ApplicationController

  before_action :set_report, only: [:edit,:update,:report,:delete_condition,:set_report_permission,:delete_report,:composite_report,:chart_report]
  require 'matrix'

  # 员工常用报表
  def index
   	@q = SearchParams.new(params[:search_params] || {}) 
    search_params = @q.attributes(self)
    # 辅助工具报表
    test_report = params[:report_type] == "test" ? "and report_type = 10" : "and report_type != 10"
    @reports = TemporaryReport.default_where(search_params).where("parent_id < 1 #{test_report} ").order(id: :desc).page(params[:page]).per(20)
  end

  def new
    @temporary_report = TemporaryReport.new
    @report_conditions = [ReportCondition.new(name:"开始时间",report_key:"start_time",report_condition:" and created_at >= '\#{@start_time}' ",default_value:Time.now.yesterday.to_s(:db2)) , ReportCondition.new(name:"结束时间",report_key:"end_time",report_condition:" and created_at < '\#{@end_time}' ",default_value:Time.now.to_s(:db2))]
  end

  def edit 
    @report_conditions = @temporary_report.report_conditions
  end

  def create 
    TemporaryReport.transaction do 
      @temporary_report = TemporaryReport.new(report_params)
      params[:temporary_report][:report_condition].each do |index, spec|
        if spec[:report_key].present? 
          @temporary_report.report_conditions.new(spec.permit!)
        end
      end
      if params[:parent_report]
        @temporary_report.parent_id = -1
        @temporary_report.report_type = 1
      end
      @temporary_report.save
      if params[:parent_report]
        params[:parent_report].each_with_index do |report,i|
          parent_report = params[:parent_report].keys.inject({}){|o,j| o[j] = params[:parent_report][j][i] ; o }
          TemporaryReport.create(parent_report.merge(parent_id:@temporary_report.id , name:@temporary_report.name , report_type:1))
        end
      end 
    end  
  end

  def update
    TemporaryReport.transaction do 
      @temporary_report.update(report_params)
      params[:temporary_report][:report_condition].each do |index, spec|
        spec.permit!
        if spec[:id].present?
          new_spec = ReportCondition.find(spec[:id])
          new_spec.attributes =  spec
          new_spec.save
        elsif spec[:report_key].present? 
          new_spec = @temporary_report.report_conditions.new(spec)
          new_spec.save
        end
      end
      if params[:parent_report]
        params[:parent_report][:columns].each_with_index do |report,i|
          parent_report = params[:parent_report].keys.inject({}){|o,j| o[j] = params[:parent_report][j][i] ; o }
          report = parent_report["id"] ? TemporaryReport.find(parent_report["id"].to_i) : TemporaryReport.new
          report.assign_attributes(parent_report.merge(parent_id:@temporary_report.id , name:@temporary_report.name , report_type:1))
          report.save
        end
      end
    end  
  end

  def delete_condition
    @report_condition = ReportCondition.find params[:condition_id].to_i
    @report_condition_id = @report_condition.id
    @report_condition.delete
  end

  def delete_report
    @temporary_report_id = @temporary_report.id
    @temporary_report.delete
  end

  # 权限设置
  def set_report_permission
    if params[:temporary_report]
      params[:temporary_report].permit!
      roles = params[:temporary_report][:roles] !=[""] && params[:temporary_report][:employee_ids] !=[""] ? params[:temporary_report][:roles].compact : [1]
      employee_ids = params[:temporary_report][:employee_ids] !=[""] ? params[:temporary_report][:employee_ids].compact : [1]
      @temporary_report.update({roles: roles, employee_ids: employee_ids}) 
    end
  end

  # 合并报表
  def composite_report
    if params[:temporary_report]
      @temporary_report.update(composite_report_params) 
    end
  end

  # 设置图标
  def chart_report
    if @temporary_report.temporary_charts.present?
      @temporary_chart = @temporary_report.temporary_charts.last
    else
      @temporary_chart = TemporaryChart.new(temporary_report_id:@temporary_report.id)
    end
    if params[:temporary_chart]
      @temporary_chart.update(chart_report_params) 
    end
  end

  # 更改负责人
  def change_employees
    @options = params[:roles] ? Role.find(params[:roles].map{|_|_.to_i}).map{|_|_.employees}.flatten.uniq : []
    render :partial => "change_employees" 
  end

  # 报表查看
  def report
    # 解析下载excell参数
    if params[:report_params].present?
      #ruby2.4已fix可直接解析
      #report_params = params[:report_params].split("&").map{|_| a = _.split("="); a[1] = CGI.unescape("#{a[1]}") ; a if a.size == 2 }.compact  
      params[:search_params] = params[:report_params]
    end  

    jump_links

    if params[:xls] && !@temporary_report.composite?
      to_xls
    else
      @q = SearchParams.new(params[:search_params] || {}) 
      # 配置条件
      @report_conditions = @temporary_report.report_conditions
      # 赋值默认值显示
      unless params[:search_params].present?
        params[:search_params] = {}
        @report_conditions.each do |c|
          params[:search_params][c.report_key] = c.default_value
        end
      end
      # 报表名称
      @report_name = @temporary_report.name
      # 搜索html
      @head_html = @temporary_report.head_html
      # 报表字段
      @columns = @temporary_report.columns.split(" ")
      # 报表解析
      @execute_reports = ExecuteReport.new(@temporary_report.get_report_sql(params)).report 
      @reports = Kaminari.paginate_array(@execute_reports, total_count: @execute_reports.size).page(params[:page]).per(20)
      # 关联报表子报表
      association if @temporary_report.association? || @temporary_report.composite?
      # 合并报表子报表
      composite if @temporary_report.composite?
      # 图表
      charts if @temporary_report.temporary_charts
    end 
  end

  # 关联报表子报表
  def association
    @child_columns = []
    @child_reports = []
    @execute_child_reports = []
    @child_temporary_reports = @temporary_report.child_reports
    @child_temporary_reports.each do |child|
      @child_columns << child.columns.split(" ")
      child_reports = ExecuteReport.new(child.get_report_sql(params)).report 
      @execute_child_reports << child_reports
      @child_reports << Kaminari.paginate_array(child_reports, total_count: child_reports.size).page(params[:page]).per(20)
    end
  end

  # 合并报表子报表
  def composite
    @moder_columns = []
    @moder = []
    arr = ('a'..'z').to_a
    composite_sentence = @temporary_report.composite_sentence.split(",")
    composite_sentence.each do |_|
      mod = arr.index(_[0])
      moder = (mod == 0 ? @execute_reports : @execute_child_reports[mod-1])
      mod_columns_size = _[1].to_i
      @moder << moder.map{|_|_[mod_columns_size]}
      moder_column = (mod == 0 ? @columns[mod_columns_size] : @child_columns[mod-1][mod_columns_size])
      @moder_columns << moder_column
    end
    # 矩阵行列倒置
    @reports = Matrix.columns(@moder).to_a
    @columns = @moder_columns
    # 合并报表子报表的下载xls
    if params[:xls]
      send_data ExecuteReport.to_xlsx(@report_name,@columns,@reports), type: 'text/xls', filename: "#{Time.now}#{@report_name}.xls"
    else
      @reports = Kaminari.paginate_array(@reports, total_count: @reports.size).page(params[:page]).per(20) 
    end
  end

  # 图表
  def charts
    @charts = []  

    @temporary_report.temporary_charts.each do |chart|
      chart_item = {}

      if chart.chart_data.present?
        @chart_reports = ExecuteReport.new(chart.get_report_sql(params)).report 
        chart_item[:yy] =  chart.y_axis.split(",")
        chart_item[:y_data] =  Matrix.columns( @chart_reports.map{|_|  _[1..-1].map{|a| a.to_f } } ).to_a
        # xx轴一般为时间力度
        chart_item[:xx] = @chart_reports.map{|_|_[0]}.uniq
      else
        @chart_columns = []
        @chart_data = []
        arr = ('a'..'z').to_a
        composite_sentence = chart.y_axis.split(",")
        composite_sentence.each do |_|
          mod = arr.index(_[0])
          moder_data = (mod == 0 ? @execute_reports : @execute_child_reports[mod-1])
          mod_columns_size = _[1..-1].to_i
          @chart_data << moder_data.map{|_| _[mod_columns_size].to_f }
          moder_column = (mod == 0 ? @columns[mod_columns_size] : @child_columns[mod-1][mod_columns_size])
          @chart_columns << moder_column
        end

        chart_item[:yy] =  @chart_columns
        chart_item[:y_data] = @chart_data
        # xx轴一般为时间力度
        chart_item[:xx] = @execute_reports.map{|_|_[0]}.uniq
      end

      @charts << chart_item
    end
  end

  
  # 获取超链接配置
  def jump_links
    if @temporary_report.jump_links
      @jump_links = eval(@temporary_report.jump_links)
    end
  end

  # 普通报表下载
  def to_xls
    @columns = @temporary_report.columns.split(" ")
    execute_report = ExecuteReport.new(@temporary_report.get_report_sql(params))
    send_data execute_report.to_xlsx(@report_name,@columns), type: 'text/xls', filename: "#{Time.now}#{@report_name}.xls" 
  end


  private

  def report_params
    params.require(:temporary_report).permit(:name,
                                             :jump_links,
                                             :columns,
                                             :note,
                                             :base_sql,
                                             :head_html)
  end

  def composite_report_params
    params.require(:temporary_report).permit(:report_type,
                                             :composite_sentence)
  end

  def chart_report_params
    params.require(:temporary_chart).permit(:temporary_report_id,:chart_data,:note,
                                             :tab_x_axis,:y_axis)
  end

  def report_permission_params
    params.require(:temporary_report).permit(:roles,:employee_ids)
  end

  def set_report
    @temporary_report = TemporaryReport.find(params[:id])
  end


end