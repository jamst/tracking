class CreateTrackingRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :tracking_records do |t|
       t.string  "opxpid", comment: "平台id"
       t.string  "opxid", comment: "监控id"
       t.datetime  "time_now", comment: "当前时间"	
       t.string   "domain", comment: "监控id"	
       t.string   "opxtitle", comment: "连接描述"
       t.string   "opxreferrer", comment: "跳来路由"
       t.string   "opxurl", comment: "当前url"  
       t.string   "ip", comment: "监控ip"
       t.text     "opxuserAgent", comment: "浏览器类型等信息"
       t.datetime "created_at", null: false, comment: "创建日期"
       t.datetime "updated_at", null: false, comment: "修改日期"
    end
  end
end
