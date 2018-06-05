class FaceCuttingStrategy

  attr_accessor :rayStart, :rayEnd, :rayStartPosition, :rayStartOrientation, :rayEndPosition, :rayEndOrientation, :gcode

  def initialize

    $rayStart = Geom::Line.new()

    $rayEnd = Geom::Line.new()

    $rayStartPosition = Geom::Point3d.new(0,0,0)

    $rayEndPosition = Geom::Point3d.new(0,0,0)

    $rayStartOrientation = Array.new(2)

    $rayEndOrientation = Array.new(2)

  end

end

class ManipulatedVertex

end

class ExtendedEdge

end

module CalculateCuttingStrategy

  def OuterVertices face

    return Array.new()

  end

  def GenerateCuttingLine point, vector

    # Point at random height in the cuttingface

    # Direction vector

    return Geom::Line.new()

  def Raytest line

    # remove all lines from model

    # different layer?

    # linetest

    return false

  end

  def DrawCuttingStrategy faceCuttingStrategy

  end

end
