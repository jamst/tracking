class TicketRecord < ApplicationRecord
	
  belongs_to :ticket
  belongs_to :mod_entity, polymorphic: true

end