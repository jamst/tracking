# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
class CreateTables < ActiveRecord::Migration[5.0]
  def change
    create_table "employees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", comment: "员工表" do |t|
        t.string   "email",                            default: "",  null: false, comment: "email"
        t.string   "encrypted_password",               default: "",  null: false, comment: "密码"
        t.integer  "parent_id",                        default: 0,                comment: "上级ID"
        t.datetime "created_at",                                     null: false, comment: "创建日期"
        t.datetime "updated_at",                                     null: false, comment: "修改日期"
        t.string   "name",                 limit: 20,                             comment: "名字"
        t.integer  "department_id",                    default: 0,   null: false, comment: "部门ID"
        t.integer  "position_id",                      default: 0,   null: false, comment: "职位： 0:其它 6:财务 7:产品经理...."
        t.integer  "position_level",                   default: 0,   null: false, comment: "行政级别 0:员工 1:主管 2:经理 3:总监"
        t.integer  "job_status",                       default: 1,   null: false, comment: "在职状态, 1:在职, -1:离职"
        t.float    "weight",               limit: 24,  default: 1.0, null: false, comment: "权重"
        t.date     "joined_on",                                                   comment: "入职日期"
        t.integer  "gender",                                                      comment: "性别 0:男 1:女"
        t.string   "mobile",               limit: 30,                             comment: "手机"
        t.string   "qq",                   limit: 30,                             comment: "QQ"
        t.string   "office_tel",           limit: 30,                             comment: "公司电话"
        t.date     "dob",                                                         comment: "生日"
        t.datetime "remember_created_at",                                         comment: "记住创建日期"
        t.integer  "deputy_department_id",             default: 0,                comment: "副部门"
        t.string   "avatar",               limit: 100,                            comment: "员工头像"
        t.integer  "assign_count",                     default: 0,                comment: "分配点数"
        t.integer  "handover_id",                      default: 0,                comment: "交接人"
        t.index ["email"], name: "index_employees_on_email", unique: true, using: :btree
    end

    create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", comment: "角色表" do |t|
        t.string   "name",          comment: "角色名称"
        t.string   "name_cn",       comment: "中文名"
        t.datetime "created_at",    comment: "创建日期"
        t.datetime "updated_at",    comment: "修改日期"
        t.index ["name"], name: "index_roles_on_name", using: :btree
    end

    create_table "temporary_charts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
        t.integer  "temporary_report_id",                            comment: "关联的报表"
        t.string   "tab_x_axis",                                     comment: "x轴tab"
        t.string   "y_axis",                                         comment: "y轴数据"
        t.text     "chart_data",          limit: 65535,              comment: "图表数据定义(取关联报表数据源或重定义sql数据源)"
        t.string   "note",                                           comment: "备注"
        t.datetime "created_at",                        null: false
        t.datetime "updated_at",                        null: false
    end

    create_table "temporary_reports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", comment: "临时报表" do |t|
        t.string   "name",                                                      comment: "名称描述"
        t.text     "base_sql",           limit: 65535,                          comment: "sql脚本"
        t.text     "note",               limit: 65535,                          comment: "报表需求描述"
        t.text     "columns",            limit: 65535,                          comment: "报表字段"
        t.text     "head_html",          limit: 65535,                          comment: "搜索html"
        t.datetime "created_at",                                   null: false, comment: "创建时间"
        t.datetime "updated_at",                                   null: false, comment: "修改时间"
        t.integer  "active",                           default: 1,              comment: "是否有效,0:无效, 1:有效, -1:删除"
        t.string   "roles",                                                     comment: "相关的角色权限"
        t.integer  "parent_id",                        default: 0,              comment: "n父子关系，-1当前为父报表，o默认值"
        t.integer  "report_type",                      default: 0,              comment: "报表类型，0普通报表，1关联报表 ,2合成报表"
        t.text     "composite_sentence", limit: 65535,                          comment: "合并报表描述dsl"
        t.string   "jump_links",         limit: 512,                            comment: "攥取链接设置"
    end

    create_table "report_conditions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
        t.integer  "temporary_report_id"
        t.string   "name",                             comment: "条件名称"
        t.string   "report_key",                       comment: "条件字段"
        t.string   "report_condition",                 comment: "条件脚本"
        t.string   "view_type",                        comment: "条件展示方式：select/下拉框，text/文本框，data/时间框"
        t.string   "view_value",                       comment: "当为下拉框时，显示内容"
        t.datetime "created_at",          null: false
        t.datetime "updated_at",          null: false
        t.string   "default_value",                    comment: "默认值"
        t.index ["temporary_report_id"], name: "index_report_conditions_on_temporary_report_id", using: :btree
    end

    create_table "employees_roles", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", comment: "员工权限表" do |t|
        t.integer "employee_id", comment: "员工ID"
        t.integer "role_id",     comment: "员工权限"
        t.index ["employee_id", "role_id"], name: "index_employees_roles_on_employee_id_and_role_id", using: :btree
    end

    create_table "employees_temporary_reports", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    	t.integer "employee_id"
    	t.integer "temporary_report_id"
    	t.index ["employee_id", "temporary_report_id"], name: "temporary_reports_employees_index", using: :btree
    end
    
  end  
end

CreateTables.new.change

# email to me!
em = Employee.create(email:"107422244@qq.com",password:"11111111",name:"jamst")


