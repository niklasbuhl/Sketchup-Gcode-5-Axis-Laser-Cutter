require 'sketchup'

class ManipulatedVertex

  attr_accessor :origVertex, :thisVector, :projectedVector, :projectedValue

  def initialize vertex

    #puts "Creating new manipulated vertex"

    @origVertex = vertex

    #puts "Original Vertex: #{origVertex.to_s}"

    @thisVector = Geom::Vector3d.new(vertex.position.x, vertex.position.y, vertex.position.z)

    #puts "This Vertex: #{thisVector.to_s}"

    @projectedVector = Geom::Vector3d.new(vertex.position.x, vertex.position.y, vertex.position.z)

    @projectedValue = 0

    #puts "Projected Vertex: #{projectedVector.to_s}"

  end

end



class ExtendedEdge

end


class FaceCuttingStrategy

  attr_accessor :face, :laserStart, :laserEnd, :laserStartPosition, :laserStartOrientation, :laserEndPosition, :laserEndOrientation, :topVertex, :bottomVertex, :outerVertices, :vertexCount, :manipulatedVertices

  def initialize face

    @face = face

    #puts "Face: #{@face.to_s}"
    #puts "Face-type: #{$face.typename}"

    # Laser start position [x,y,z]
    @laserStartPosition = Geom::Point3d.new(0,0,0)

    # Laser end position [x,y,z]
    @laserEndPosition = Geom::Point3d.new(0,0,0)

    # Laser start orientation [a,b]
    @laserStartOrientation = Array.new(0,0)

    # Laser end orientation [a,b]
    @laserEndOrientation = Array.new(0,0)

    # Array to keep track of the outer vertices
    @outerVertices = Array.new()

    # Keep vertex count
    @vertexCount = @face.vertices.count

    # Initalize edge array
    @manipulatedVertices = Array.new

    # Assign all vertices to an array for analyse
    @face.vertices.each do |vertex|

      tempManipulatedVertex = ManipulatedVertex.new vertex

      @manipulatedVertices.push(tempManipulatedVertex)

    end

  end

end


module CalculateCuttingStrategy

  def self.TopBottomVertices faceCuttingStrategy

    # Sort the vertices in the cutting face for high-< to low-z
    faceCuttingStrategy.manipulatedVertices.sort! { |x,y| y.origVertex.position.z <=> x.origVertex.position.z }
    #puts "Analyzing Top and Bottom vertices."

    # SSet higest Z
    faceCuttingStrategy.topVertex = faceCuttingStrategy.manipulatedVertices.first.origVertex
    #puts "Top Z: #{cuttingFace.topVertex.position.z}"

    # Set lowest Z
    faceCuttingStrategy.bottomVertex = faceCuttingStrategy.manipulatedVertices.last.origVertex
    #puts "Bottom Z: #{cuttingFace.bottomVertex.position.z}"

  end

  def self.OuterVertices faceCuttingStrategy

    #puts "Finding Outer Vertices (Version 0.1)"

    #thisFace = faceCuttingStrategy.face

    #puts "Face: #{thisFace.to_s}"
    #puts "Face: #{thisFace.typename}"

    #puts ""
    #puts ""

    # Get face normal vector
    normal = faceCuttingStrategy.face.normal
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
    originVector = Geom::Vector3d.new(faceCuttingStrategy.manipulatedVertices.first.origVertex.position.to_a)
    faceCuttingStrategy.manipulatedVertices.first.projectedValue = 0
    #puts "Start vertex: #{originVector.to_s}"

    #originVector = faceCuttingStrategy.manipulatedVertices.first.thisVector

    # Get vector between origin vertice and all others (2 or 3)

    for i in 1..(faceCuttingStrategy.vertexCount-1)

      #puts ""

      # Creating the vector from start vertex to the other vertices

      # Vector to the vertex
      vertexVector = Geom::Vector3d.new(faceCuttingStrategy.manipulatedVertices[i].projectedVector)

      #puts "Vertex Vector: #{vertexVector.to_s}"

      # Calculate vector between start and other vertex
      vertexVector = vertexVector - originVector

      # Remove Z variable
      vertexVector.z = 0

      #puts "Offset Vector: #{vertexVector.to_s}"

      # Project this vectors on the XY rotated normal vector
      faceCuttingStrategy.manipulatedVertices[i].projectedVector = ProjectVector vertexVector, normal

      #puts "Projected Vector: #{faceCuttingStrategy.manipulatedVertices[i].projectedVector.to_s}"

      # Get the angle between the rotated normal vector and the projected vector - Should be 0 or PI
      projectedAngle = normal.angle_between(faceCuttingStrategy.manipulatedVertices[i].projectedVector)
      #puts "Projected Vector angle between normal: #{projectedAngle}"

      # Get the relative length of the projected vector from the origin - The projected value
      projectedLength = faceCuttingStrategy.manipulatedVertices[i].projectedVector.length

      # If the projected angle is PI, then assign the value to negative
      if projectedAngle < 1
        projectedLength = projectedLength * -1
      end

      # Save the projectedValue in the vertex
      faceCuttingStrategy.manipulatedVertices[i].projectedValue = projectedLength

    end

    # puts ""

    # Take the length of these vector and sort them, including the origin which is zero
    faceCuttingStrategy.manipulatedVertices.sort! { |x,y| x.projectedValue <=> y.projectedValue }

    # faceCuttingStrategy.manipulatedVertices.each { |i| puts "Projected Value: #{i.projectedValue}"}

    #puts "Highest projectedValue: #{faceCuttingStrategy.manipulatedVertices.first.projectedValue}"
    #puts "Lowest projectedValue: #{faceCuttingStrategy.manipulatedVertices.last.projectedValue}"

    # Save the references to the original vertices
    faceCuttingStrategy.outerVertices[0] = faceCuttingStrategy.manipulatedVertices.first.origVertex
    faceCuttingStrategy.outerVertices[1] = faceCuttingStrategy.manipulatedVertices.last.origVertex

    #puts "Outer most side vertex A: #{faceCuttingStrategy.outerMostSideVertexA.position.to_s}"
    #puts "Outer most side vertex B: #{faceCuttingStrategy.outerMostSideVertexB.position.to_s}"

    #$entities.add_edges Geom::Point3d.new(0,0,0), Geom::Point3d.new(faceCuttingStrategy.outerVertices[0].position.to_a)
    #$entities.add_edges Geom::Point3d.new(0,0,0), Geom::Point3d.new(faceCuttingStrategy.outerVertices[1].position.to_a)

  end

  def self.GenerateCuttingLine point, vector

    # --- This can be optimized ---

    zBottomDiff = -point.z
    zTopDiff = $tableHeight - point.z

    vectorToBottom = Geom::Vector3d.new(0, 0, zBottomDiff)
    vectorToTop = Geom::Vector3d.new(0, 0, zTopDiff)

    #DrawLine point, vectorToBottom, $entities
    #DrawLine point, vectorToTop, $entities

    vectorToBottom = ProjectVector vectorToBottom, vector
    vectorToTop = ProjectVector vectorToTop, vector

    vectorToBottom = ExtendVector vectorToBottom, 'z', zBottomDiff
    vectorToTop = ExtendVector vectorToTop, 'z', zTopDiff

    bottomPoint = point + vectorToBottom.to_a
    topPoint = point + vectorToTop.to_a

    #puts "Top Point: #{topPoint}"
    #puts "Bottom Point: #{bottomPoint}"

    #DrawLine point, vectorToBottom, $entities
    #DrawLine point, vectorToTop, $entities

    $entities.add_line bottomPoint, topPoint

    #puts "#{vectorToBottom}"
    #puts "#{vectorToTop}"

    #line = Geom::Line(point, vector)

    # Point at random height in the faceCuttingStrategy

    # Direction vector

    return [topPoint, bottomPoint]

  end

  def self.ExtendVector vector, xyz, value

    case xyz
    when 'x' || 0
      scalar = value / vector.x
    when 'y' || 1
      scalar = value / vector.y
    when 'z' || 2
      scalar = value / vector.z
    else
      return false
    end

    # Division by 0 gives NaN
    scalar = 0 if scalar.nan?

    vector = ScaleVector vector, scalar

    return vector

  end

  def self.ScaleVector vector, scalar

    #puts "Scalar before: #{scalar}"

    scalar = scalar.abs

    #puts "Scalar after: #{scalar}"

    vector.x = vector.x * scalar
    vector.y = vector.y * scalar
    vector.z = vector.z * scalar

    return vector

  end

  def self.RayTest line

    # remove all lines from model

    # different layer?

    # linetest

    return false

  end

  def self.PlaneTest lineA, lineB

    # Create a plane and check if it not hitting anything.

  end

  def self.ProjectVector vectorA, vectorB

    #puts "Projecting Vector A: #{vectorA.to_s} onto Vector B: #{vectorB.to_s}"

    scalar = ( vectorA % vectorB ) / vectorB.length ** 2

    #puts "Scalar: #{scalar}"

    vector = Geom::Vector3d.new(vectorB.x * scalar, vectorB.y * scalar, vectorB.z * scalar)

    #puts "Result: #{vector.to_s}"

    return vector

  end

  def self.UpVector faceCuttingStrategy

    parallelvector = faceCuttingStrategy.face.normal

    parallelvector.z = 0

    x = parallelvector.x
    y = parallelvector.y

    parallelvector.x = -y
    parallelvector.y = x

    vector = faceCuttingStrategy.face.normal * parallelvector

    vector.length = 10

    #puts "Up Vector: #{vector}"

    point = Geom::Point3d.new(faceCuttingStrategy.outerVertices[1].position.to_a)

    #DrawLine point, vector, $entities

    #pointA = Geom::Point3d.new(faceCuttingStrategy.outerVertices[1].position.to_a)
    #pointB = Geom::Point3d.new(faceCuttingStrategy.outerVertices[1].position.to_a) + vector.to_a

    #$entities.add_edges pointA, pointB

    return vector

  end

  def self.DrawLine point, vector, entities

    pointA = point
    pointB = point + vector.to_a

    entities.add_line pointA, pointB

  end

end
