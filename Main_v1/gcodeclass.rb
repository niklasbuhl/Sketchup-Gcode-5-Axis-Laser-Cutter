require 'sketchup.rb'
class GCode

  # The GCode object(class)

  # X translation in mm
  # Y translation in mm
  # Z translation in mm
  # A rotation in degrees
  # B rotation in degrees

  Struct.new(:x, :y, :z, :a, :b)

end
