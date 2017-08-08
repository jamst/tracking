class CreateTrackingTags < ActiveRecord::Migration[5.0]
  def change
    create_table :tracking_tags do |t|
       t.string  "dimain"
       t.string  "link_name"
       t.string  "tag_name"	
       t.string  "contect"
       t.datetime "created_at", null: false, comment: "创建日期"
       t.datetime "updated_at", null: false, comment: "修改日期"
    end
  end
end
