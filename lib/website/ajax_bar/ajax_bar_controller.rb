module Website
  module AjaxBar
    class  AjaxBarController < ActionController::Base
      helper :all
      PROCESS_OK_TEMPLETE_FILE    = File.expand_path("../views/ok.js.erb",__FILE__)
      PROCESS_FAIL_TEMPLETE_FILE = File.expand_path("../views/fail.js.erb",__FILE__)
      PROCESS_ERROR_TEMPLETE_FILE = File.expand_path("../views/error.js.erb",__FILE__)
      def ajax
        op = params[:op].to_s.strip
        id = params[:id].to_i
        partial = params[:p].to_s
        @entry = get_class.find_by_id(id)
        @entry.current_employee = current_employee if @entry.respond_to?(:current_employee)
        @entry.current_ability = current_ability if @entry.respond_to?(:current_ability)
        op_method = "#{op}_it".to_sym
        if !op.blank? && @entry.is_ready_to?(op) && @entry.respond_to?(op_method) 
          if @entry.method(op_method).arity == 1
            flag = @entry.send(op_method,params[:ov].to_s.strip)
          else
            flag = @entry.send(op_method)
          end
          if flag
            render :update, :file => PROCESS_OK_TEMPLETE_FILE,  :formats => [:js]
          else
            Rails.logger.info(@entry.errors.to_json)
            render :update, :file => PROCESS_FAIL_TEMPLETE_FILE,  :formats => [:js]
          end
        else
          render :update, :file => PROCESS_ERROR_TEMPLETE_FILE,  :formats => [:js]
        end
      end

      protected
      def get_class
        params[:class].blank? ? nil : (params[:class].camelize.constantize rescue nil)
      end
      def current_ability
        @current_ability ||= ::Ability.new(current_employee)
      end
    end
  end
end
