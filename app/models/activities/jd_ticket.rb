module Activities
  class JdTicket < ApplicationRecord
    has_one :jdticket_welfare

    enum status: {
      unissued: 0,
      issued: 1
    }
  end
end

