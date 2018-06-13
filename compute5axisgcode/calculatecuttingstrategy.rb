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


class FaceCuttingStrategy

  attr_accessor :face, :rays, :cuttable, :strategy, :laserStart, :laserEnd, :laserStartPosition, :laserStartOrientation, :laserEndPosition, :laserEndOrientation, :topVertex, :bottomVertex, :outerVertices, :vertexCount, :manipulatedVertices

  def initialize face

    # Reference to the visual face
    @face = face

    # Laser Cutting Rays [Point3d, Point3d]
    @rays = Array.new()
    @cuttable = false
    @strategy = ""

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

  def self.ClearCutRay

    puts "Clearing Cuts and Ray Arrays and Edges v0.3" if $debugClearCutRayArray

    $laserCutArray.each do |cut|

      next if cut.nil?

      next if cut.deleted?

      cut.erase! if cut.is_a? (Sketchup::Edge)

    end

    $laserRayArray.each do |ray|

      next if ray.nil?

      next if ray.deleted?

      ray.erase! if ray.is_a? (Sketchup::Edge)

    end

    $laserCutArray.clear
    $laserRayArray.clear

  end

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
    faceCuttingStrategy.manipulatedVertices.sort! { |xP,yP| xP.projectedValue <=> yP.projectedValue }

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

    #$entities.add_line bottomPoint, topPoint

    #puts "#{vectorToBottom}"
    #puts "#{vectorToTop}"

    #line = Geom::Line(point, vector)

    # Point at random height in the faceCuttingStrategy

    # Direction vector

    return [topPoint, bottomPoint]

  end

  def self.FirstStrategy faceCuttingStrategy, cutting_index

    # Calculate cutting dirction vector
    vector = UpVector(faceCuttingStrategy)

    # Get the position of the outer vertices
    pointA = faceCuttingStrategy.outerVertices[0].position
    pointB = faceCuttingStrategy.outerVertices[1].position

    # --- First Raytest ---
    faceCuttingStrategy.rays[0] = CalculateCuttingStrategy.GenerateCuttingLine pointA, vector
    faceCuttingStrategy.rays[1] = CalculateCuttingStrategy.GenerateCuttingLine pointB, vector

    rayA = CalculateCuttingStrategy.RayTest faceCuttingStrategy.rays[0], faceCuttingStrategy.face
    rayB = CalculateCuttingStrategy.RayTest faceCuttingStrategy.rays[1], faceCuttingStrategy.face

    # Successful strategy 1
    if !rayA & !rayB

      faceCuttingStrategy.cuttable = true
      faceCuttingStrategy.strategy = "1"
      puts "Face #{cutting_index}. Strategy 1 is successful!" if $debugStrategy1
      return true

    end

    puts "Face #{cutting_index}. Strategy 1 is not successful, proceding..." if $debugStrategy1

    return false

  end

  def self.SecondStrategy faceCuttingStrategy, cutting_index

    rayA = nil
    rayB = nil
    vector = nil

    # For each outer vertex
    faceCuttingStrategy.outerVertices.each_with_index do |outerVertex, vertex_index|

      # Find cuttable edge from outerVertex

      edges = outerVertex.edges
      puts "Listing edges: #{edges}" if $debugStrategy2

      # For each edge connected to the outerVertices
      edges.each do |edge|

        #puts "This is: #{edge}" if $debugStrategy2

        # Check if the edge is on the face
        next unless edge.used_by?(faceCuttingStrategy.face)

        # Calculate the angle of the edge
        angle = edge.line[1].angle_between(Geom::Vector3d.new(0,0,1))

        puts "Edge Angle: #{angle * (180 / Math::PI) }. Less than: #{ (Math::PI / 4) * (180 / Math::PI) } or higher then: #{ 3 * Math::PI / 4 * (180 / Math::PI) }" if $debugStrategy2

        # Check if the edge is more that 45 degress and less than 135
        next if angle > Math::PI / 4 && angle < 3 * Math::PI / 4

        # Check if the edge is less that 135 degress
        #next unless angle > 3 * Math::PI / 4 && angle > Math::PI / 4

        puts "Angle is alright" if $debugStrategy2

        # Get the vector from the edge
        vector = edge.line[1] # Vector from the edge

        puts "Vector of line: #{vector.to_s}" if $debugStrategy2

        break

      end

      # Get point and vector for cutting line
      pointA = outerVertex.position # position from outerVertex

      # Generate cutting line from edge(vector) and outer vertex

      faceCuttingStrategy.rays[vertex_index] = CalculateCuttingStrategy.GenerateCuttingLine pointA, vector

      # Raytest
      rayA = CalculateCuttingStrategy.RayTest faceCuttingStrategy.rays[vertex_index], faceCuttingStrategy.face

      $entities.add_line(faceCuttingStrategy.rays[vertex_index]) if $debugStrategy2rays

      # If this ray did not succeed
      if rayA

        puts "Face #{cutting_index}. Stragety 2.#{vertex_index}a was not successful, proceeding..." if $debugStrategy2
        next

      end

      # Find the vertice furthest away
      faceCuttingStrategy.manipulatedVertices.each do |manipulatedVertex|

        manipulatedVertex.projectedValue = manipulatedVertex.origVertex.position.distance_to_line(pointA, vector)

      end

      # Sort manipulatedVertex array to the projectedValue(distance(), Take the distances and sort them, including the origin which is zero
      faceCuttingStrategy.manipulatedVertices.sort! { |x,y| x.projectedValue <=> y.projectedValue }

      if $debugStrategy2

        #faceCuttingStrategy.manipulatedVertices.each { |manipulatedVertex| puts "All: #{manipulatedVertex.projectedValue}"}
        #puts "Highest: #{faceCuttingStrategy.manipulatedVertices.last.projectedValue}"

      end

      pointB = faceCuttingStrategy.manipulatedVertices.last.origVertex.position

      # Generate cutting line from the vertex and vector from the first edge

      tempRayB = CalculateCuttingStrategy.GenerateCuttingLine pointB, vector

      #faceCuttingStrategy.rays[1-vertex_index] = CalculateCuttingStrategy.GenerateCuttingLine pointB, vector

      # Raytest: Outer vertex cutting line and cutting line from the vertices
      rayB = CalculateCuttingStrategy.RayTest tempRayB, faceCuttingStrategy.face

      $entities.add_line(faceCuttingStrategy.rays[1-vertex_index]) if $debugStrategy2rays

      # Second ray test successful, break the loop for each
      if !rayA && !rayB

        faceCuttingStrategy.cuttable = true
        faceCuttingStrategy.rays[1-vertex_index] = tempRayB
        faceCuttingStrategy.strategy = "2.#{vertex_index}"

        puts "Face #{cutting_index}. Strategy 2.#{vertex_index} was successful!" if $debugStrategy2

        puts "Breaking loop." if $debugStrategy2

        return true

      end

      puts "Face #{cutting_index}. Strategy 2.#{vertex_index}b was not successful, proceeding..." if $debugStrategy2

    end

    return false



=begin

    # Second ray test successful
    if !rayA && !rayB
      puts "Next (debugStrategy2)" if $debugStrategy2
      next
    end

=end

  end

  def self.ThirdStrategy faceCuttingStrategy, cutting_index

    # As they are already saved from above they should just be checked.

    puts "Trying third strategy"

    rayA = CalculateCuttingStrategy.RayTest faceCuttingStrategy.rays[0], faceCuttingStrategy.face
    $entities.add_line(faceCuttingStrategy.rays[0]) if $debugStrategy3rays
    puts "RayA was successful" if !rayA && $debugStrategy3

    rayB = CalculateCuttingStrategy.RayTest faceCuttingStrategy.rays[1], faceCuttingStrategy.face
    $entities.add_line(faceCuttingStrategy.rays[1]) if $debugStrategy3rays
    puts "RayB was successful" if !rayB && $debugStrategy3

    # If they did not hit anything, proceed to next cuttingFace
    if !rayA && !rayB

      faceCuttingStrategy.cuttable = true
      faceCuttingStrategy.strategy = "3"

      puts "Face #{cutting_index}. Strategy 3 was successful!"

      # Success!
      return true

    end

    puts "Face #{cutting_index}. Strategy 3 was not successful, proceeding..."

    # Failed!
    return false

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

  def self.RayTest ray, face

    puts "Testing ray..." if $debugRaytest

    hiddenArray = Array.new()

    #line = ray

    vector = Geom::Vector3d.new(ray[1] - ray[0])

    point = ray[0]

    ray = [point, vector]

    hit = true

    # First Hit

    # --- The Great Ray Obstacle Check ---

    # Loop
    while hit

      # Try and hit
      entity = $model.raytest(ray, true)

      # If nothing is hit
      if entity == nil

        puts "Nothing is hit!" if $debugRaytest
        hit = false

        # Unhide all hidden faces
        hiddenArray.each { |hiddenEntity| hiddenEntity.hidden = false }

        puts "Ray test complete!" if $debugRaytest

        return hit

      end

      foundPoint = entity[0]
      foundEntity = entity[1].first

      puts "We hit something!" if $debugRaytest
      #puts "#{entity}"
      #puts "#{foundEntity.vertices}"


      # --- Vertex Check ---

=begin
      foundVertex = nil

      face.vertices.each do |vertex|

        # Comparing two Point3d with Sketchup tolerance
        # http://ruby.sketchup.com/Geom/Point3d.html#==-instance_method
        foundVertex = vertex if foundPoint == vertex.position

      end

      # Check if point is used by the faces
      break unless foundVertex.used_by?(face)
=end




      # --- Triangulation Check ---
      #
      # Using 2D Point Polygon to check if it inside...
      # https://ruby.sketchup.com/Geom.html#point_in_polygon_2D-class_method

      # Face vertices

      xyPolygon = Array.new()
      yzPolygon = Array.new()
      xzPolygon = Array.new()

      # Create polygon arrays with the three 2D coordinate systems.
      face.vertices.each { |vertex| xyPolygon.push(Geom::Point3d.new(vertex.position.x, vertex.position.y, 0))}
      face.vertices.each { |vertex| yzPolygon.push(Geom::Point3d.new(vertex.position.y, vertex.position.z, 0))}
      face.vertices.each { |vertex| xzPolygon.push(Geom::Point3d.new(vertex.position.x, vertex.position.z, 0))}

      x = foundPoint.x
      y = foundPoint.y
      z = foundPoint.z

      # Create three new 2D points from the 3D point
      xyPoint = Geom::Point3d.new(x,y,0)
      yzPoint = Geom::Point3d.new(y,z,0)
      xzPoint = Geom::Point3d.new(x,z,0)

      # Check each if the point is inside the 2D polygon
      xyHit = Geom.point_in_polygon_2D(xyPoint, xyPolygon, true)
      yzHit = Geom.point_in_polygon_2D(yzPoint, yzPolygon, true)
      xzHit = Geom.point_in_polygon_2D(xzPoint, xzPolygon, true)

      #puts "xyHit hit" if xyHit
      #puts "yzHit hit" if yzHit
      #puts "xzHit hit" if xzHit

      # If the point is outside one of the 2D polygon it should be outside the face and break the loop, as something else is found.
      if !xyHit || !yzHit || !xzHit
        puts "Object hit is outside the face!" if $debugRaytest

        # Unhide all hidden faces
        hiddenArray.each { |hiddenEntity| hiddenEntity.hidden = false }

        puts "Ray test complete!" if $debugRaytest

        return hit

      end

      # --- Hide the found object ---
      #
      # If the point is not inside the face, it

      puts "Object hit is inside the face, hide it and try to shoot again..." if $debugRaytest

      # Hide the face/edge and repeat
      foundEntity.hidden = true

      # Remember the hidden item
      hiddenArray.push(foundEntity)

    end

    # ---

    puts "This will never occur..." if $debugRaytest

    # Unhide all hidden faces
    hiddenArray.each { |hiddenEntity| hiddenEntity.hidden = false }

    puts "Ray test complete!" if $debugRaytest

    # Return result
    return hit

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

    #point = Geom::Point3d.new(faceCuttingStrategy.outerVertices[1].position.to_a)

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

  def self.LaserCut faceCuttingStrategy

    # Find the z-value based top-point, bottom-point and percentage.
    # 0% being the top, 100% being the bottom.

    topZ = faceCuttingStrategy.topVertex.position.z
    bottomZ = faceCuttingStrategy.bottomVertex.position.z

    z = topZ - bottomZ

    # Vector z-value
    z = (z / 100) * (100 - $laserFocalPercent)

    puts "z: #{z}" if $debugLaserCut

    vectorA = Geom::Vector3d.new(faceCuttingStrategy.rays[0][0] - faceCuttingStrategy.rays[0][1])
    vectorB = Geom::Vector3d.new(faceCuttingStrategy.rays[1][0] - faceCuttingStrategy.rays[1][1])

    unless z == 0
      bottomRayA = ExtendVector vectorA, "z", z
      bottomRayB = ExtendVector vectorB, "z", z
    else
      bottomRayA = bottomRayB = Geom::Vector3d.new(0,0,0)
    end

    topRayA = ScaleVector vectorA.normalize, $laserFocalPoint
    topRayB = ScaleVector vectorB.normalize, $laserFocalPoint

    if $testPrintingWithoutZaxis

      topRayA = ExtendVector topRayA, "z", $laserFocalPoint
      topRayB = ExtendVector topRayB, "z", $laserFocalPoint

    end

    #topRayA = ExtendVector vectorA, "z", $laserFocalPoint
    #topRayB = ExtendVector vectorB, "z", $laserFocalPoint

    faceCuttingStrategy.laserStartPosition = faceCuttingStrategy.rays[0][1] + bottomRayA + topRayA
    faceCuttingStrategy.laserEndPosition = faceCuttingStrategy.rays[1][1] + bottomRayB + topRayB

  end

  def self.CalculateOrientation faceCuttingStrategy

    vectorA = Geom::Vector3d.new(faceCuttingStrategy.rays[0][0] - faceCuttingStrategy.rays[0][1])
    vectorB = Geom::Vector3d.new(faceCuttingStrategy.rays[1][0] - faceCuttingStrategy.rays[1][1])

    faceCuttingStrategy.laserStartOrientation = CalculateABangle vectorA
    faceCuttingStrategy.laserEndOrientation = CalculateABangle vectorB

  end

  def self.CalculateABangle vector

    # Make sure the z-value of the vector is positive.
    vector = vector.reverse if vector.z < 0

    # Create the reference z-vector
    zVector = Geom::Vector3d.new(0,0,1)

    # Project the vector to XZ plane.
    xzVector = Geom::Vector3d.new(vector.x,0,vector.z)

    # Project the vector to YZ plane.
    yzVector = Geom::Vector3d.new(0,vector.y,vector.z)

    # Angle between two 3d vectors, always positive.
    a = zVector.angle_between(yzVector)
    b = zVector.angle_between(xzVector)

    # Since the function always returns a positive angle between the vectors, depending on the vector orienation is must be inverted.
    a = a * (-1) if vector.y > 0
    b = b * (-1) if vector.x < 0

    # Convert radians to degrees
    a = a * (180 / Math::PI)
    b = b * (180 / Math::PI)

    # Round
    a = a.round($gcodeAngleDecimals)
    b = b.round($gcodeAngleDecimals)

    puts "Vector [x]: #{vector.x}, [y]: #{vector.y}, [z]: #{vector.z}" if $debugCalculateABangle
    puts "Angle [a]: #{a}, angle [b]: #{b}" if $debugCalculateABangle

    puts "Vector [x]: #{vector.x}, [y]: #{vector.y}, [z]: #{vector.z}, Angle [a]: #{a}, angle [b]: #{b}" if $debugViften

    return a, b

  end

end
