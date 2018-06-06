# 访客
module Ad
  class Audience < ApplicationRecord
    serialize :targeting_ips

  end
end