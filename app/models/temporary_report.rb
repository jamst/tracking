class TemporaryReport < ApplicationRecord
  include Activeable
  has_many :report_conditions	
  has_many :temporary_charts 
  has_and_belongs_to_many :employees, :join_table => :employees_temporary_reports
  accepts_nested_attributes_for :report_conditions, allow_destroy: true, :reject_if => :all_blank
  
  serialize :roles

  enum report_type: {
    general: 0,       #普通报表
    association: 1,   #关联报表
    composite: 2 ,    #合成报表
    test: 10          #辅助工具报表
  }

  def get_report_sql(params)
    conditions = self.general?||self.test?||self.parent_id == -1 ? self.report_conditions : self.parent.report_conditions
    conditions.each do |c|
      eval %Q(	
        @#{c.report_key} = params[:search_params].present? && params[:search_params]["#{c.report_key}"].present? ? params[:search_params]["#{c.report_key}"] :  "" 
        @condition_#{c.report_key} = params[:search_params].present? && params[:search_params]["#{c.report_key}"].present? ? "#{c.report_condition}" : ""
      )
    end
    sql = eval %Q( %Q(#{self.base_sql}) ) 
  end

  def child_reports
    TemporaryReport.where(parent_id:self.id)
  end

  def parent
    TemporaryReport.find(self.parent_id)
  end

end
