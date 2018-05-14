require 'sketchup.rb'

# Class for manipulation of edges and extended information

# Class for manipulation of vertices without changing the original

class ManipulatedVertex

  attr_accessor :origVertex, :thisVector, :projectedVector, :connectedVertexA, :connectedVertexB, :projectedValue

  def initialize vertex

    puts "Creating new manipulated vertex"

    @origVertex = vertex

    puts "Original Vertex: #{origVertex.to_s}"

    @thisVector = Geom::Vector3d.new(vertex.position.x, vertex.position.y, vertex.position.z)

    puts "This Vertex: #{thisVector.to_s}"

    @projectedVector = Geom::Vector3d.new(vertex.position.x, vertex.position.y, vertex.position.z)

    @projectedValue = 0

    puts "Projected Vertex: #{projectedVector.to_s}"

  end

end

class ManipulatedEdge

  attr_accessor :origEdge, :cutable, :neighboorEdges, :oppositeEdge

  # oppositeEdge is if the face is a quad

  def initialize edge

    @origEdge = edge

    @oppositeEdge = nil

    @cutable = false

    # Check for neighboor edges

    # Check for cutability, not more than PI/4 i Z-axis

    vector = Geom::Vector3d.new((edge.line)[1])

    angle = vector.angle_between(Geom::Vector3d.new(0,0,-1))

    #angle - Math::PI if angle > Math::PI

    @cutable = true if angle < Math::PI/4 || angle > Math::PI*3/4

    puts "#{vector.to_s} and is angled: #{angle.radians}, Cutable: #{cutable}"

    # Neighboor Edges on same face

    @neighboorEdges = Array.new

  end

  def ClassifyEdges face

    edges = face.edges

    edges.each do |edge|

      next if edge == @origEdge

      if @origEdge.start == edge.start || @origEdge.start == edge.end || @origEdge.end == edge.start || @origEdge.end == edge.end

        @neighboorEdges.push(edge)

        puts "Neighboor edge: #{@neighboorEdges.last}"

        next

      end

      @oppositeEdge = edge

      puts "Opposite Edge: #{@oppositeEdge}"

    end

  end

end

# Class for cutting faces .. Under Development
class CuttingFace


  attr_accessor :face, :edgeCount, :edges, :vertexCount, :manipulatedVertices, :manipulatedEdges, :verticesXY, :topVertex, :bottomVertex, :outerMostSideVertexA, :outerMostSideVertexB, :xyAngleOffset


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

      tempEdge.ClassifyEdges face

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
    #puts "Analyzing Top and Bottom vertices."

    # SSet higest Z
    cuttingFace.topVertex = cuttingFace.manipulatedVertices.first.origVertex
    #puts "Top Z: #{cuttingFace.topVertex.position.z}"

    # Set lowest Z
    cuttingFace.bottomVertex = cuttingFace.manipulatedVertices.last.origVertex
    #puts "Bottom Z: #{cuttingFace.bottomVertex.position.z}"

  end

  def self.XYAngleOffset cuttingFace

    #puts "Finding XY angle between X-axis and face XY normal."

    xVector = Geom::Vector3d.new(1, 0, 0)

    newVector = Geom::Vector3d.new(cuttingFace.face.normal.x, cuttingFace.face.normal.y, 0)

    cuttingFace.xyAngleOffset = xVector.angle_between(newVector)

    #puts "Angle: #{cuttingFace.xyAngleOffset.radians}"

  end

  def self.SideVertices cuttingFace

    thisEntity = cuttingFace.face.parent

    #puts "Entity: #{thisEntity.to_s}"
    #puts "Entity: #{thisEntity.typename}"

    #puts ""
    #puts ""

    # Get face normal vector
    normal = cuttingFace.face.normal
    #puts "Original Normal #{normal.to_s}"

    # Get XY of normal vector
    normal.z = 0
    #puts "XY Normal #{normal.to_s}"

    # Rotate XY normal vector pi/2
    x = normal.x
    y = normal.y

    normal.x = y
    normal.y = -x
    #puts "Rotated XY Normal #{normal.to_s}"

    # Start in a vertice
    originVector = Geom::Vector3d.new(cuttingFace.manipulatedVertices.first.origVertex.position.to_a)
    cuttingFace.manipulatedVertices.first.projectedValue = 0
    #puts "Start vertex: #{originVector.to_s}"

    #originVector = cuttingFace.manipulatedVertices.first.thisVector

    # Get vector between origin vertice and all others (2 or 3)

    for i in 1..(cuttingFace.vertexCount-1)

      #puts ""

      # Creating the vector from start vertex to the other vertices

      # Vector to the vertex
      vertexVector = Geom::Vector3d.new(cuttingFace.manipulatedVertices[i].projectedVector)

      #puts "Vertex Vector: #{vertexVector.to_s}"

      # Calculate vector between start and other vertex
      vertexVector = vertexVector - originVector

      # Remove Z variable
      vertexVector.z = 0

      #puts "Offset Vector: #{vertexVector.to_s}"

      # Project this vectors on the XY rotated normal vector
      cuttingFace.manipulatedVertices[i].projectedVector = ProjectVector vertexVector, normal

      #puts "Projected Vector: #{cuttingFace.manipulatedVertices[i].projectedVector.to_s}"

      # Get the angle between the rotated normal vector and the projected vector - Should be 0 or PI
      projectedAngle = normal.angle_between(cuttingFace.manipulatedVertices[i].projectedVector)
      #puts "Projected Vector angle between normal: #{projectedAngle}"

      # Get the relative length of the projected vector from the origin - The projected value
      projectedLength = cuttingFace.manipulatedVertices[i].projectedVector.length

      # If the projected angle is PI, then assign the value to negative
      if projectedAngle < 1
        projectedLength = projectedLength * -1
      end

      # Save the projectedValue in the vertex
      cuttingFace.manipulatedVertices[i].projectedValue = projectedLength

    end

    puts ""

    # Take the length of these vector and sort them, including the origin which is zero
    cuttingFace.manipulatedVertices.sort! { |x,y| x.projectedValue <=> y.projectedValue }

    cuttingFace.manipulatedVertices.each { |i| puts "Projected Value: #{i.projectedValue}"}

    #puts "Highest projectedValue: #{cuttingFace.manipulatedVertices.first.projectedValue}"
    #puts "Lowest projectedValue: #{cuttingFace.manipulatedVertices.last.projectedValue}"

    # Save the references to the original vertices
    cuttingFace.outerMostSideVertexA = cuttingFace.manipulatedVertices.first.origVertex
    cuttingFace.outerMostSideVertexB = cuttingFace.manipulatedVertices.last.origVertex

    #puts "Outer most side vertex A: #{cuttingFace.outerMostSideVertexA.position.to_s}"
    #puts "Outer most side vertex B: #{cuttingFace.outerMostSideVertexB.position.to_s}"

    edgeA = $entities.add_edges Geom::Point3d.new(0,0,0), Geom::Point3d.new(cuttingFace.outerMostSideVertexA.position.to_a)
    edgeB = $entities.add_edges Geom::Point3d.new(0,0,0), Geom::Point3d.new(cuttingFace.outerMostSideVertexB.position.to_a)

  end

  # Edges available as start/end cutting vectors
  def self.AvailableCuttingEdges cuttingFace

  end

  def self.PlaneVector cuttingFace

  end

  def self.ProjectVector vectorA, vectorB

    #puts "Projecting Vector A: #{vectorA.to_s} onto Vector B: #{vectorB.to_s}"

    scalar = ( vectorA % vectorB ) / vectorB.length ** 2

    #puts "Scalar: #{scalar}"

    vector = Geom::Vector3d.new(vectorB.x * scalar, vectorB.y * scalar, vectorB.z * scalar)

    #puts "Result: #{vector.to_s}"

    return vector

  end

end
