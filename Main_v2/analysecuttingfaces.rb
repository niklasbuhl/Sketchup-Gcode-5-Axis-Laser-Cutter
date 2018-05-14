require 'sketchup.rb'

# Class for manipulation of edges and extended information

# Class for manipulation of vertices without changing the original

class ManipulatedVertex

  attr_accessor :origVertex, :thisVector, :projectedVector, :connectedVertexA, :connectedVertexB

  def initialize vertex

    puts "Creating new manipulated vertex"

    @origVertex = vertex

    puts "Original Vertex: #{origVertex.to_s}"

    @thisVector = Geom::Vector3d.new(vertex.position.x, vertex.position.y, vertex.position.z)

    puts "This Vertex: #{thisVector.to_s}"

    @projectedVector = Geom::Vector3d.new(vertex.position.x, vertex.position.y, vertex.position.z)

    puts "Projected Vertex: #{projectedVector.to_s}"

  end

end

class ManipulatedEdge

  attr_accessor :origEdge, :cutable, :neighboor

  def initialize edge

    @origEdge = edge

    # Check for neighboor edges

    # Check for cutability, not more than PI/4 i Z-axis

    vector = Geom::Vector3d.new((edge.line)[1])

    angle = vector.angle_between(Geom::Vector3d.new(0,0,-1))

    #angle - Math::PI if angle > Math::PI

    @cutable = false if angle < Math::PI/4

    puts "#{vector.to_s} and is angled: #{angle.radians}"



    #

  end

end

# Class for cutting faces .. Under Development
class CuttingFace

  attr_accessor :face, :edgeCount, :edges, :vertexCount, :manipulatedVertices, :verticesXY, :topVertex, :bottomVertex, :sideVertexA, :sideVertexB, :xyAngleOffset

  def initialize face

    # Keep pointer to face
    @face = face

    # Keep edge count
    @edgeCount = @face.edges.count

    # Keep vertex count
    @vertexCount = @face.vertices.count

    # Initalize edge array
    @manipulatedEdges = Array.new

    # Assign all edges to the array for analyse
    @face.edges.each do |edge|

      tempEdge = ManipulatedEdge.new edge

      @manipulatedEdges.push(tempEdge)

    end

    # Initialize vertex array
    @manipulatedVertices = Array.new

    # Assign all vertices to an array for analyse
    @face.vertices.each do |vertex|

      tempManipulatedVertex = ManipulatedVertex.new vertex

      @manipulatedVertices.push(tempManipulatedVertex)

    end

    puts "Creating new cutting face. With #{@vertexCount} vertices, #{@edgeCount} edges."

    # Print before sort
    #@vertices.each { |vertex| puts "#{vertex.position.z}"}

    # Sorting vertices for high to low
    #@vertices.sort! { |x,y| y.position.z <=> x.position.z }

    # Print after sort
    #@vertices.each { |vertex| puts "#{vertex.position.z}"}

  end

end

module AnalyseCuttingFaces

  def self.TopBottomZ cuttingFace

    # Sort the vertices in the cutting face for high-< to low-z
    cuttingFace.manipulatedVertices.sort! { |x,y| y.origVertex.position.z <=> x.origVertex.position.z }
    puts "Analyzing Top and Bottom vertices."
    # SSet higest Z
    cuttingFace.topVertex = cuttingFace.manipulatedVertices.first.origVertex
    puts "Top Z: #{cuttingFace.topVertex.position.z}"
    # Set lowest Z
    cuttingFace.bottomVertex = cuttingFace.manipulatedVertices.last.origVertex
    puts "Bottom Z: #{cuttingFace.bottomVertex.position.z}"

  end

  def self.XYAngleOffset cuttingFace

    puts "Finding XY angle between X-axis and face XY normal."

    xVector = Geom::Vector3d.new(1, 0, 0)

    newVector = Geom::Vector3d.new(cuttingFace.face.normal.x, cuttingFace.face.normal.y, 0)

    cuttingFace.xyAngleOffset = xVector.angle_between(newVector)

    puts "Angle: #{cuttingFace.xyAngleOffset.radians}"

  end

  def self.SideVertices cuttingFace

    # Get face normal vector
    normal = cuttingFace.face.normal
    puts "Original Normal #{normal.to_s}"

    # Get XY of normal vector
    normal.z = 0
    puts "XY Normal #{normal.to_s}"

    # Rotate XY normal vector pi/2
    x = normal.x
    y = normal.y

    normal.x = y
    normal.y = -x
    puts "Rotated XY Normal #{normal.to_s}"

    # Start in a vertice
    originVector = Geom::Vector3d.new(cuttingFace.manipulatedVertices.first.origVertex.position.to_a)
    puts "Start vertex: #{originVector.to_s}"

    #originVector = cuttingFace.manipulatedVertices.first.thisVector

    # Get vector between origin vertice and all others (2 or 3)

    for i in 1..(cuttingFace.vertexCount-1)

      # Creating the vector from start vertex to the other vertices

      # Vector to the vertex
      vertexVector = Geom::Vector3d.new(cuttingFace.manipulatedVertices[i].projectedVector)

      puts "Offset Vector: #{vertexVector.to_s}"

      # Calculate vector between start and other vertex
      cuttingFace.manipulatedVertices[i].projectedVector = vertexVector - originVector

      # Remove Z variable
      cuttingFace.manipulatedVertices[i].projectedVector.z = 0

      puts "Projected Vector: #{cuttingFace.manipulatedVertices[i].projectedVector.to_s}"

      # Project this vectors on the XY rotated normal vector
      

      # Get the relative length of the projected vector from the origin

    end

    # Take the length of these vector and sort them, including the origin which is zero



  end

  # Edges available as start/end cutting vectors
  def self.AvailableCuttingEdges cuttingFace

  end

  def self.PlaneVector cuttingFace

  end

end
