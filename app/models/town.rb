require "hydra"

class Town < ActiveFedora::Base
  has_relationship "sections", :has_part,  :type=>Section
end