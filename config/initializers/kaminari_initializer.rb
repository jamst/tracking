module Kaminari
  module Helpers
    class Select < Tag
      include Link
      def page
        @options[:page]
      end
    end
    class Paginator < Tag
      def select_tag(page)
        @last = Select.new @template, @options.merge(:page => page)
      end
    end
  end
end


