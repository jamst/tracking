module Website::AjaxBar::AjaxBarModel
  def is_ready_to?(method)
    if self.respond_to?("is_ready_to_#{method}?")
      self.send("is_ready_to_#{method}?")
    else
      true
    end
  end
end

ActiveRecord::Base.class_eval {include Website::AjaxBar::AjaxBarModel}
