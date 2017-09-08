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

    create_table "employees_roles", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", comment: "员工权限表" do |t|
        t.integer "employee_id", comment: "员工ID"
        t.integer "role_id",     comment: "员工权限"
        t.index ["employee_id", "role_id"], name: "index_employees_roles_on_employee_id_and_role_id", using: :btree
    end

  end  
end

CreateTables.new.change

# email to me!
em = Employee.create(email:"107422244@qq.com",password:"11111111",name:"jamst")


