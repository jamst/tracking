class CreateTrackingRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :tracking_records do |t|
       t.string  "opxpid", comment: "平台id"
       t.string  "opxid", comment: "监控id"
       t.datetime  "time_now"	
       t.string   "domain"	
       t.string   "opxtitle"
       t.string   "opxreferrer", comment: "跳来路由"
       t.string   "opxurl"  
       t.string   "ip"
       t.text     "opxuserAgent"
       t.datetime "created_at", null: false, comment: "创建日期"
       t.datetime "updated_at", null: false, comment: "修改日期"
    end
  end
end
