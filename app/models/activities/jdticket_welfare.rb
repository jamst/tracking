module Activities
  class JdticketWelfare < ApplicationRecord
    belongs_to :order_detail
    belongs_to :activity
    belongs_to :activity_detail
    belongs_to :jd_ticket
    belongs_to :user
    has_one :ticket, as: :mod_entity

    enum status: {
  	    isa_initial: 0,
  	    isa_confirmed: 1,
  	    isa_finished: 2,
  	    isa_deleted: -1
  	  }

  	after_create :ticket_init 

    # 发起人获取首张监测券
    def ticket_init
      Ticket.create(activity_id:self.activity_id,user_id:self.user_id,mod_entity_type:"Activities::JdticketWelfare",mod_entity_id:self.id,ticket_type:2,name:"#{self.denomination}元京东券")
    end  

    def show_package
      self.live_package
    end

    # 匹配发放京东券
    def self.payfor_tickets(activity_id=nil)
    	
    	if activity_id.present?
          welfares = Activities::JdticketWelfare.where(status:["isa_initial","isa_confirmed"],activity_id:activity_id)
    	else
          welfares = Activities::JdticketWelfare.where(status:["isa_initial","isa_confirmed"])
    	end

	    welfares.each do |welfare|
	       order_detail = welfare.order_detail 
	       # 采购订单已收款，或者采购订单已发货
	       if order_detail.ship_done? || order_detail.all_paid?
		      activity_detail = welfare&.activity_detail
		      order_package = order_detail.sum_package.to_f
		      # 如果单位不一致转化单位
		      order_package = order_detail.convert_unit(order_package, order_detail.package_unit, activity_detail&.package_unit, 1).to_f  if activity_detail&.package_unit != order_detail.package_unit
		      denomination,live = activity_detail&.match_package(order_package.to_f)
		        if denomination.present? 
		        	live_package = "#{live.match(/[1-9]\d*/).to_s}#{activity_detail&.package_unit}"
		            Activities::JdticketWelfare.transaction do 
		              jd_ticket = Activities::JdTicket.unissued.where(denomination:denomination).first
		              # 如果有金额匹配的京东券则发放
		              if jd_ticket
		                jd_ticket.update(status:"issued")
		                welfare.update(denomination:denomination,live_package:live_package,jd_ticket_id:jd_ticket.id,card_password:jd_ticket.card_password,status:"isa_finished",expiry_on:jd_ticket.expiry_on) 
		                Ticket.where(mod_entity_type:"Activities::JdticketWelfare",mod_entity_id:welfare.id).update(status:"isa_finished",expiry_on:jd_ticket.expiry_on)
		                test_send_sms(welfare.user.mobile, welfare.user.name, activity_detail&.chemical&.name_cn , denomination)
		              end  
		            end
		        else
		            Activities::JdticketWelfare.transaction do 
		              welfare.update(status:"isa_deleted") 
		              Ticket.where(mod_entity_type:"Activities::JdticketWelfare",mod_entity_id:welfare.id).update(status:"isa_deleted")
		            end  
		        end
		   end     
	    end  
	end

    # 给对应的客户发送提醒短信
	def self.test_send_sms(mobile, user_name, chemical_name , denomination)
	    params = {}
	    params["account"] = 'shyishih'
	    params["pswd"] = 'andy_gxl19841027'
	    params["mobile"] = mobile
	    params["msg"] = "尊敬的#{user_name}，您的#{chemical_name}订单奖励已激活，#{denomination}元京东券可使用了。请登陆会员中心>卡券中心查看。"
	    params["needstatus"] = false
	    url = URI.parse("http://222.73.117.156/msg/HttpBatchSendSM")
	    Net::HTTP.start(url.host, url.port) do |http|
	      req = Net::HTTP::Post.new(url.path)
	      req.set_form_data(params)
	      xml_str =  http.request(req).body
	      response_status = xml_str.split(",")[1]
	      return response_status
	    end
	end


  end
end

