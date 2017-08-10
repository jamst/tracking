class CreateTrackingTags < ActiveRecord::Migration[5.0]
  def change
    create_table :tracking_tags do |t|
       t.string  "dimain", comment: "对应网站"
       t.string  "link_name", comment: "对应连接"
       t.string  "tag_name"	, comment: "对应热点名称"
       t.string  "contect"	, comment: "简述"
       t.datetime "created_at", null: false, comment: "创建日期"
       t.datetime "updated_at", null: false, comment: "修改日期"
    end
  end
end
