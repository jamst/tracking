class CreateTrackingDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :tracking_details do |t|
       t.string  "opxpid", comment: "平台id"
       t.string   "opxurl", comment: "当前url"  
       t.datetime "created_at", null: false, comment: "创建日期"
       t.datetime "updated_at", null: false, comment: "修改日期"
    end
  end
end
