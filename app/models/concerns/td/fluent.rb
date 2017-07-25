module Td::Fluent
    extend ActiveSupport::Concern

     module ClassMethods
      require 'fluent-logger'
        def connection
          @connection || FLUENT
        end
        
        # Specify the connection object that this class should use. 
        def connect_using conn
          @connection = conn
        end

        # Specify the label string for Fluent.
        def label_as label
          @label = label
        end

        # Display the label being used for this class.
        def label
          @label ||= self.new.class.to_s.underscore.gsub('/', '.')
        end

        # Log to Fluent
        def << payload
          payload["uuid"] = SecureRandom.uuid.to_s.strip unless payload.has_key? "uuid"
            #binding.pry
          self.connection.post self.label, payload
        end
    end
end

