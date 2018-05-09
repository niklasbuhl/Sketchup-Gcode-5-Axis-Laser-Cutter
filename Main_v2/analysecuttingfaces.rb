require 'sketchup.rb'

# Class for cutting faces .. Under Development
class CuttingFace

  attr_accessor :face, :edgeCount, :edges, :vertexCount, :vertices, :verticesXY, :topZ, :bottomZ, :xyAngleOffset

  def initialize face

    @face = face

    @edgeCount = @face.edges.count

    @vertices = @face.vertices

    @vertexCount = @vertices.count

    puts "Creating new cutting face. With #{@vertexCount} vertices, #{@edgeCount} edges."

    # Print before sort
    #@vertices.each { |vertex| puts "#{vertex.position.z}"}

    # Sorting vertices for high to low
    #@vertices.sort! { |x,y| y.position.z <=> x.position.z }

    # Print after sort
    #@vertices.each { |vertex| puts "#{vertex.position.z}"}

  end

end

class ManipulatedVertex

  attr_accessor :origVertex, :thisVertex

  def initialize vertex

    @origVertex = vertex

    @thisVertex = Geom::Vector3d.new(vertex.x, vertex.y, vertex.z)

  end

end

module AnalyseCuttingFaces

  def self.TopBottomZ cuttingFace

    # Sort the vertices in the cutting face for high-< to low-z
    cuttingFace.vertices.sort! { |x,y| y.position.z <=> x.position.z }
    puts "Analyzing Top and Bottom vertices."
    # SSet higest Z
    cuttingFace.topZ = cuttingFace.vertices.first.position.z
    puts "Top Z: #{cuttingFace.topZ}"
    # Set lowest Z
    cuttingFace.bottomZ = cuttingFace.vertices.last.position.z
    puts "Bottom Z: #{cuttingFace.bottomZ}"

  end

  def self.XYAngleOffset cuttingFace

    puts "Finding XY angle between X-axis and face XY normal."

    xVector = Geom::Vector3d.new(1, 0, 0)

    newVector = Geom::Vector3d.new(cuttingFace.face.normal.x, cuttingFace.face.normal.y, 0)

    cuttingFace.xyAngleOffset = xVector.angle_between(newVector)

    puts "Angle: #{cuttingFace.xyAngleOffset.radians}"

  end

  def self.SideVertices cuttingFace

  end

  # Edges available as start/end cutting vectors
  def self.AvailableCuttingEdges cuttingFace

  end

end
