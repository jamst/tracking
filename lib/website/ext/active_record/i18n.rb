module Website
  module Ext
    module ActiveRecord
      module I18n
        extend ActiveSupport::Concern
        I18N_ATTR_PREFIX = /^i18n_attr_/
        NAME_OF_PREFIX = /^name_of_/
        HASH_OF_PREFIX = /^i18n_hash_/
        def method_missing(method, *args, &block)
          c = method.to_s
          if c =~ I18N_ATTR_PREFIX 
            col = c.sub(I18N_ATTR_PREFIX,'')
            display_model_status(self.class, col, self.send(col.to_sym),*args) if self.respond_to?(col)
          elsif c =~ NAME_OF_PREFIX 
            col = c.sub(NAME_OF_PREFIX,'')
            eval("#{self.class.name}::#{col.upcase}.invert[self.#{col}]") if eval("#{self.class.name}.constants.include?(:#{col.upcase})")
          elsif c =~ HASH_OF_PREFIX 
            col = c.sub(HASH_OF_PREFIX,'')
            fetch_model_status_list col
          else
            super
          end
        end

        def display_model_status(model,attribute,value,opt={})
          return if value.nil?
          return '' if value.blank?
          model_name = model.superclass != ApplicationRecord ?  model.superclass.name : model.name
          # if ['active'].include?(attribute.to_s.strip)
          #   s = ::I18n.t("activerecord.status.#{attribute}.#{value}", default: value) 
          # else
          #   s = ::I18n.t("activerecord.status.#{model_name.underscore}.#{attribute}.#{value}", default: value)
          # end
          if ::I18n.exists?("activerecord.status.#{attribute}.#{value}") 
            s = ::I18n.t("activerecord.status.#{attribute}.#{value}", default: value)
          else
            s = ::I18n.t("activerecord.status.#{model_name.underscore}.#{attribute}.#{value}", default: value)
          end          
          if opt[:css]
            s = %Q{<span class="ui compacted label #{model_name.underscore} #{attribute} #{value} basic"> #{s} </span>}  unless opt[:exept] && (opt[:exept].include? value)
          end
          s
        end

        def fetch_model_status_list(attribute)
          if ::I18n.exists?("activerecord.status.#{self.class.name.underscore}.#{attribute}") 
            key = "activerecord.status.#{self.class.name.underscore}.#{attribute}"
          else
            key = "activerecord.status.#{attribute}"
          end  
          return {} if !::I18n.backend.exists?(::I18n.config.locale, key)
          ::I18n.backend.translate(::I18n.config.locale, key).stringify_keys
        end


      end
    end
  end
end
