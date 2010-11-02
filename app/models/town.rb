require "hydra"

class Town < Location
  has_relationship "sections", :has_part,  :type=>Section
end