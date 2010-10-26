require "hydra"

class Section < Location
  has_relationship "town", :has_part, :type=>Town, :inbound=>true
  has_relationship "lots", :has_part,  :type=>Lot
end