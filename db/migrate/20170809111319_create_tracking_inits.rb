class CreateTrackingInits < ActiveRecord::Migration[5.0]
  def change
    create_table :tracking_inits do |t|
       t.integer  "yn_cache" , comment: "是否缓存"
       t.integer  "yn_shuabing" , comment: "是否刷屏"
       t.integer  "shuabing_rake"	, comment: "刷新频率"
       t.text  "tracking_target", comment: "指定追踪对象"
       t.datetime "created_at", null: false, comment: "创建日期"
       t.datetime "updated_at", null: false, comment: "修改日期"	
    end
  end
end
