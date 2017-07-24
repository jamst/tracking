module Website
  module Ext
    module ActiveRecord
      module Cancan
        extend ActiveSupport::Concern
        included do
          attr_accessor :current_employee, :current_ability
          def can?(*args)
            current_ability.can?(*args)
          end

          def cannot?(*args)
            current_ability.cannot?(*args)
          end
        end
      end
    end
  end
end

