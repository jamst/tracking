# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.wrappers :bootstrap, :tag => 'div', :class => 'control-group', :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :tag => 'div', :class => 'controls' do |ba|
      ba.use :input
      ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
      ba.use :hint,  :wrap_with => { :tag => 'p', :class => 'help-block' }
    end
  end
  config.wrappers :semantic_simple, :tag => 'div', :class => 'field', :error_class => 'field error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :input
  end
  config.wrappers :semantic, :tag => 'div', :class => 'field', :error_class => 'inline field error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.use :input
  end
  config.wrappers :semantic_search_form, :tag => 'div', :class => 'column' do |b|
    b.use :html5
    b.use :placeholder
    b.use :input
  end

  config.wrappers :prepend, :tag => 'div', :class => "control-group", :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :tag => 'div', :class => 'controls' do |input|
      input.wrapper :tag => 'div', :class => 'input-prepend' do |prepend|
        prepend.use :input
      end
      input.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
      input.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
    end
  end

  config.wrappers :append, :tag => 'div', :class => "control-group", :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :tag => 'div', :class => 'controls' do |input|
      input.wrapper :tag => 'div', :class => 'input-append' do |append|
        append.use :input
      end
      input.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
      input.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
    end
  end

  config.wrappers :toggle, :class => 'ui checkbox toggle' do |b|
    b.use :input
  end

  # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
  # Check the Bootstrap docs (http://twitter.github.com/bootstrap)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.form_class = 'content ui form'
  config.default_wrapper = :semantic
  config.button_class = 'ui primary button'
  config.error_notification_class = 'ui error message'
  config.label_class = ''
end
module SimpleForm
  module Components
    module Labels
      extend ActiveSupport::Concern

      module ClassMethods #:nodoc:
        def translate_required_html
          ''
        end
      end
    end
  end
end
