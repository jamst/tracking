class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :mod_entity, polymorphic: true

	enum status: {
	    isa_initial: 0,
	    isa_confirmed: 1,
	    isa_finished: 2,
	    isa_deleted: -1
	}

	enum ticket_type: {
	    testing: 0,
	    discount: 1,
	    jdticket: 2
	}

end
