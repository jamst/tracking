class ExecuteReport

  attr_accessor :sql,:report
  def initialize(sql)
  	@sql = sql
    @report = execute_sql
  end

  # 解析sql
  def execute_sql
    cullent_attributes = FromDB.connection.execute(@sql)
  end

  # 生成EXCELL
  def to_xlsx(name,columns)
      file = Spreadsheet::Workbook.new
 
      list = file.create_worksheet :name => name
      list.row(0).concat columns
   
      report.each_with_index { |report, i|
        list.row(i+1).concat report
      }

      xls_report = StringIO.new 
      file.write xls_report 
      xls_report.string 
  end

  # 传参生成EXCELL
  def self.to_xlsx(name,columns,report_data)
      file = Spreadsheet::Workbook.new
 
      list = file.create_worksheet :name => name
      list.row(0).concat columns
   
      report_data.each_with_index { |report, i|
        list.row(i+1).concat report
      }

      xls_report = StringIO.new 
      file.write xls_report 
      xls_report.string 
  end

end    




