"
website/ajax_bar/ajax_bar_controller
website/ajax_bar/ajax_bar_helper
website/ajax_bar/ajax_bar_model
website/ext/active_record/cancan
website/ext/active_record/i18n
current
".split(/\n/).each do |file|
  require file unless file.blank?
end


ActiveRecord::Base.class_eval {include Website::Ext::ActiveRecord::Cancan}
ActiveRecord::Base.class_eval {include Website::Ext::ActiveRecord::I18n}
