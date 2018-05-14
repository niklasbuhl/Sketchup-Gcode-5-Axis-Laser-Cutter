require 'sketchup'

class FaceCuttingStrategy

  attr_accessor :type, :rayStartPosition, :rayStartOrientation, :rayEndPosition, :rayEndOrientation, :gcode

  def initialize

    @type = nil

    $rayStartPosition = Geom::Point3d.new(0,0,0)

    $rayEndPosition = Geom::Point3d.new(0,0,0)

    $rayStartOrientation = Array.new(2)

    $rayEndOrientation = Array.new(2)

    $gcode = Array.new(5)

  end

end

module CalculateCuttingStrategy

  def CheckPenetration

    # RAYTEST

    return true # No penetration

  end

  def CalculateXYplaneIntersection

  end

  def CalculateLaserHeight

  end

  def GenerateStrategyA cuttingFace

  end

  def GenerateStrategyB1 cuttingFace

  end

  def GenerateStrategyB2 cuttingFace

  end

  def GenerateStrategyC cuttingFace

  end

end
