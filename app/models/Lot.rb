require "hydra"

class Lot < Location
  has_relationship "section", :has_part, :type=>Section, :inbound=>true
  has_relationship "buildings", :has_part,  :type=>Building
end