module Activities
  class TestingOrderWelfare < ApplicationRecord
    	belongs_to :customer_order
    	belongs_to :activity
      has_many :tickets, as: :mod_entity

    	enum status: {
  	    isa_initial: 0,
  	    isa_confirmed: 1,
  	    isa_finished: 2,
  	    isa_deleted: -1
  	  }

      after_create :ticket_init 

      # 发起人获取首张监测券
      def ticket_init
        Ticket.create(activity_id:1,user_id:self.user_id,mod_entity_type:"Activities::TestingOrderWelfare",mod_entity_id:self.id,expiry_on:self.expiry_on,name:'云检测体验券')
      end

      # 号码兑换
      def self.welfare_ticket(user_id,spread_no)
        welfare = Activities::TestingOrderWelfare.find_by_spread_no(spread_no) 
        head_welfare = Ticket.find_by(mod_entity_type:"Activities::TestingOrderWelfare",mod_entity_id:welfare.id,user_id:user_id) if welfare.present?
        if !welfare.present?
          "请检查您的分享码是否输入正确"
        elsif welfare.user_id == user_id
          "对不起，您不能兑换自己的分享码！"
        elsif head_welfare.present?
          "您已兑换过该分享码，欢迎使用！"
        elsif welfare.spread_times < 3 && welfare.status.in?(["isa_initial","isa_confirmed"])
          Ticket.create(activity_id:1,user_id:user_id,mod_entity_type:"Activities::TestingOrderWelfare",mod_entity_id:welfare.id,expiry_on:welfare.expiry_on,get_ticket_type:1,name:'云检测体验券')
          Ticket.create(activity_id:1,user_id:welfare.user_id,mod_entity_type:"Activities::TestingOrderWelfare",mod_entity_id:welfare.id,expiry_on:welfare.expiry_on,get_ticket_type:2,name:'云检测体验券')
          welfare.spread_times += 1
          welfare.save
          "恭喜您获得了一张检测券，欢迎使用！"
        else
          "您来晚啦！此兑换码已抢兑光~"   
        end
      end
  end    
end

