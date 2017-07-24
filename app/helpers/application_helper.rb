module ApplicationHelper
	
  def select_options_from_enum(model,attribute,opts=nil)
    options = model.send(attribute.to_s.pluralize) if options.blank? && model.respond_to?(attribute.to_s.pluralize)
    return [] if options.blank?
    mappings = options.keys
    mappings.keep_if{|k| opts[:values].map(&:to_s).include?(k.to_s)} if opts && opts[:values].present? && opts[:values].is_a?(Array)
    mappings.map{|key| [display_model_status(model,attribute,key),key]}
  end

  def display_model_status(model,attribute,value)
    return if value.nil?
    if ::I18n.exists?("activerecord.status.#{model.name.underscore}.#{attribute}.#{value}") 
      key = "activerecord.status.#{model.name.underscore}.#{attribute}.#{value}"
    else
      key = "activerecord.status.#{attribute}.#{value}"
    end  
    I18n.t(key,:default => value)
  end

end
