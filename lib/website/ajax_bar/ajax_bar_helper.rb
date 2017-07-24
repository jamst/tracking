module Website::AjaxBar::AjaxBarHelper
  def ajax_bar(partial,entry,operations,options={}, &block)
    partial = partial.to_s.sub(Rails.root.join("app/views").to_s,'')
    dirs = partial.split("/")
    dirs[-1] = dirs.last.sub(/^_/,'').sub(/\..*/,'')
    partial = dirs.join("/")
    operations = operations.to_s.strip.split(',') unless operations.is_a?(Array)
    entry.current_employee = current_employee if entry.respond_to?(:current_employee)
    buttons = []
    operations.each do |operation|
      if entry.is_ready_to?(ajax_bar_get_operation_name(operation))
        if operation.is_a?(::String) || operation.is_a?(::Symbol)
          buttons << ajax_bar_render_link(partial,entry,{:name => operation},&block)
        elsif operation[:as].to_s.strip == 'select'
          buttons << ajax_bar_render_select(partial,entry,operation)
        elsif operation[:as].to_s.strip == 'input'
          buttons << ajax_bar_render_input(partial,entry,operation)
        elsif operation[:as].to_s.strip == 'modal_input'
          buttons << ajax_bar_render_modal_input(partial,entry,operation,&block)
        else
          buttons << ajax_bar_render_link(partial,entry, operation,&block)
        end
      end
    end
    buttons.join(' ').html_safe
  end


  def ajax_bar_element_id(entry)
    params[:element] || "#{entry.class.name.underscore}_#{entry.id}"
    #params[:element] || "#{controller_name}_#{action_name}_#{entry.class.name.underscore}_#{entry.id}"
  end

  def ajax_bar_get_operation_name(operation)
    if operation.is_a?(String) || operation.is_a?(::Symbol)
      return operation
    else
      return operation[:name]
    end
  end

  def ajax_bar_general_ajax_params(partial,entry,operation)
    ajax_params           = {}
    ajax_params[:element] = operation[:element] || ajax_bar_element_id(entry)
    ajax_params[:p]       = partial
    ajax_params[:class]   = entry.class.name.underscore
    ajax_params[:id]      = entry.id
    ajax_params[:op]      = operation[:name].to_s.strip
    ajax_params[:reload]  = operation[:reload]
    ajax_params[:remove]  = operation[:remove]
    ajax_params[:ov]  = operation[:args]
    ajax_params
  end

  def ajax_bar_render_link(partial, entry, operation,&block)
    link_params = {:remote => true, :style => "white-space: nowrap;"}
    html_params = operation.delete(:html)
    html_params = {} unless html_params.is_a?(::Hash)
    link_params = link_params.merge html_params
    link_params[:class] = 'ajax_bar' if link_params[:class].blank?
    ajax_params = ajax_bar_general_ajax_params(partial,entry,operation)
    operation_name = operation[:name].to_s.strip
    dispaly_operation_name = I18n.t("ajax_bar.#{entry.class.name.underscore}.#{operation_name}",:default => ["ajax_bar.operations.#{operation_name}".to_sym,operation_name])
    link_params[:data] ||= {}
    link_params[:data][:variation] = 'inverted'
    link_params[:data][:content] = operation[:content] || dispaly_operation_name
    if operation[:confirm]
      if operation[:confirm] == true
        link_params[:data][:confirm] = I18n.t("ajax_bar.confirm",:default => "Are you sure #{dispaly_operation_name}?",:op => dispaly_operation_name) 
      else
        link_params[:data][:confirm] = operation[:confirm]
      end
    end
    url = ajax_bar_path(ajax_params)
    if block_given?
      link_to(url.html_safe,link_params) do 
      capture({},&block)
      end
    else
      link_to(dispaly_operation_name, url.html_safe,link_params)
    end
  end

  def ajax_bar_render_select(partial, entry, operation)
    ajax_params = ajax_bar_general_ajax_params(partial,entry,operation)
    label = "#{entry.class.human_attribute_name(ajax_bar_get_operation_name(operation))}:"
    if operation[:label] == false
      label = ''
    end
    blank = ''
    if operation[:include_blank]
     blank = "<option value=\"--blank--\">#{operation[:include_blank]}</option>"
    end
    <<-HTML
    #{label}
    <select class="ajax_bar ajax_bar_#{entry.class.name.underscore} ajax_bar_#{entry.class.name.underscore}_#{ajax_bar_get_operation_name(operation)}" onchange='ajaxBar(this,#{ajax_params.to_json})'>
    #{blank}
    #{options_for_select(operation[:collection],entry.send(ajax_bar_get_operation_name(operation).to_s))}
    </select>
    HTML
  end

  def ajax_bar_render_modal_input(partial, entry, operation,&block)
    link_params = {}
    html_params = operation.delete(:html)
    html_params = {} unless html_params.is_a?(::Hash)
    link_params = link_params.merge html_params
    link_params[:class] = 'ajax_bar' if link_params[:class].blank?
    ajax_params = ajax_bar_general_ajax_params(partial,entry,operation)
    label = "#{entry.class.human_attribute_name(ajax_bar_get_operation_name(operation))}"
    if operation[:label] == false
      label = ''
    end
    uid = "ajax_bar_#{operation[:name].to_s.strip}_#{entry.id}"
    operation_name = operation[:name].to_s.strip
    dispaly_operation_name = I18n.t("ajax_bar.#{entry.class.name.underscore}.#{operation_name}",:default => ["ajax_bar.operations.#{operation_name}".to_sym,operation_name])
    link_params[:data] ||= {}
    link_params[:data][:variation] = 'inverted'
    link_params[:data][:content] = dispaly_operation_name
    link = nil
    if block_given?
     link =  link_to("javascript: ajaxBarShowModal('##{uid}_modal')",link_params) do
        capture({},&block)
      end
    else
     link =  link_to(dispaly_operation_name, "javascript: ajaxBarShowModal('##{uid}_modal')",link_params)
    end
    html =<<-HTML
    #{link}
    <div id="#{uid}_modal" class="ui modal">
    <i class="close icon"></i>
    <h2 class="ui dividing header">#{label}</h2>
    <div class="content">
    <div>
    <textarea class="ajax_bar ajax_bar_#{entry.class.name.underscore}" id="#{uid}" style="width:80%">#{entry.send(ajax_bar_get_operation_name(operation))}</textarea>
    </div>
    
    <input type="button" onclick='ajaxBar($("##{uid}")[0],#{ajax_params.to_json});ajaxBarHideModal("##{uid}_modal");' class="ui button primary mini" value="#{t("views.submit", :default => 'submit')}"/>
    </div>
    </div>
    HTML
  end

  def ajax_bar_render_input(partial, entry, operation)
    ajax_params = ajax_bar_general_ajax_params(partial,entry,operation)
    label = "#{entry.class.human_attribute_name(ajax_bar_get_operation_name(operation))}:"
    if operation[:label] == false
      label = ''
    end
    uid = "ajax_bar_#{operation[:name].to_s.strip}_#{entry.id}"
    <<-HTML
    #{label}
    <div class="ui form">
    <input class="ajax_bar ajax_bar_#{entry.class.name.underscore}" id="#{uid}" value="#{escape_javascript(entry.send(ajax_bar_get_operation_name(operation)).to_s)}" />
    <input class="ui primary button mini" type="button" onclick='ajaxBar($("##{uid}")[0],#{ajax_params.to_json})' value="#{t("views.update", :default => '更新')}"/>
    </div>
    HTML
  end
end

ActionView::Base.class_eval {include Website::AjaxBar::AjaxBarHelper}
