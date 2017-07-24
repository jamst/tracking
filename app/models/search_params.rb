class SearchParams
  extend ActiveModel::Naming
  def initialize(attributes = {})
    @attributes = (attributes || {}).stringify_keys.each{|k,v| v.to_s.strip! }
  end

  def attributes(controller = nil,focus = [])
    return @attributes if controller.blank?
    focus_attributes = focus.inject({}) {|h,i| h[i] = true; h}
    focus_attributes.merge(@attributes).inject({}){|h,i|
      m = "search_filter_#{i[0]}".downcase.strip.gsub(/[^_a-z0-9]+/,'_')
      if controller.respond_to?(m,true)
        if controller.method(m).arity == 1
          h[i[0]] = controller.send(m,i[1]) 
        else
          h[i[0]] = controller.send(m) 
        end
      else
        h[i[0]] = i[1]
      end
      h}
  end
  def params(controller = nil)
    attributes(controller)
  end

  def method_missing(method, *value)
    if method.to_s =~ /=$/
      @attributes[method.to_s.sub('=','').strip] = value
    else
      value = @attributes[method.to_s.strip]
    end
    value
  end
end
