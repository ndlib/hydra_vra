require "hydra"

class Building < Location
  has_relationship "lot", :has_part, :type=>Lot, :inbound=>true
end