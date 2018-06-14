require 'sketchup'

class ManipulatedVertex

  # Class to hold a manipulated vertex

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

    # Not cuttable yet
    @cuttable = false

    # No strategy
    @strategy = nil

    puts "Face: #{@face.to_s}" if $debugFaceCuttingStrategy
    puts "Face-type: #{$face.typename}" if $debugFaceCuttingStrategy

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

      # It there is a empty place in the array
      next if cut.nil?

      # If the cut is already deleted, it might still be in the array but the references point to a deleted object
      next if cut.deleted?

      # Delete it if it is an egde
      cut.erase! if cut.is_a? (Sketchup::Edge)

    end

    $laserRayArray.each do |ray|

      # It there is a empty place in the array
      next if ray.nil?

      # If the cut is already deleted, it might still be in the array but the references point to a deleted object
      next if ray.deleted?

      # Delete it if it is an egde
      ray.erase! if ray.is_a? (Sketchup::Edge)

    end

    # Clear both arrays
    $laserCutArray.clear
    $laserRayArray.clear

  end

  def self.TopBottomVertices faceCuttingStrategy

    # Sort the vertices in the cutting face for high-< to low-z
    faceCuttingStrategy.manipulatedVertices.sort! { |x,y| y.origVertex.position.z <=> x.origVertex.position.z }
    puts "Analyzing Top and Bottom vertices." if $debugTopBottomVertices

    # Set higest Z
    faceCuttingStrategy.topVertex = faceCuttingStrategy.manipulatedVertices.first.origVertex
    puts "Top Z: #{cuttingFace.topVertex.position.z}" if $debugTopBottomVertices

    # Set lowest Z
    faceCuttingStrategy.bottomVertex = faceCuttingStrategy.manipulatedVertices.last.origVertex
    puts "Bottom Z: #{cuttingFace.bottomVertex.position.z}" if $debugTopBottomVertices

  end

  def self.OuterVertices faceCuttingStrategy

    puts "Finding Outer Vertices (Version 0.1)"  if $debugOuterVertices

    thisFace = faceCuttingStrategy.face if $debugOuterVertices

    puts "Face: #{thisFace.to_s}" if $debugOuterVertices
    puts "Face: #{thisFace.typename}" if $debugOuterVertices

    # Get face normal vector
    normal = faceCuttingStrategy.face.normal
    puts "Original Normal #{normal.to_s}" if $debugOuterVertices

    # Get XY of normal vector
    normal.z = 0
    puts "XY Normal #{normal.to_s}" if $debugOuterVertices

    # Rotate XY normal vector pi/2
    x = normal.x
    y = normal.y
    normal.x = y
    normal.y = -x
    puts "Rotated XY Normal #{normal.to_s}" if $debugOuterVertices

    # Start in a vertice
    originVector = Geom::Vector3d.new(faceCuttingStrategy.manipulatedVertices.first.origVertex.position.to_a)
    faceCuttingStrategy.manipulatedVertices.first.projectedValue = 0
    puts "Start vertex: #{originVector.to_s}" if $debugOuterVertices

    # Get vector between origin vertice and all others (2 or 3)
    for i in 1..(faceCuttingStrategy.vertexCount-1)

      # Creating the vector from start vertex to the other vertices

      # Vector to the vertex
      vertexVector = Geom::Vector3d.new(faceCuttingStrategy.manipulatedVertices[i].projectedVector)
      puts "Vertex Vector: #{vertexVector.to_s}" if $debugOuterVertices

      # Calculate vector between start and other vertex
      vertexVector = vertexVector - originVector

      # Remove Z variable
      vertexVector.z = 0

      puts "Offset Vector: #{vertexVector.to_s}" if $debugOuterVertices

      # Project this vectors on the XY rotated normal vector
      faceCuttingStrategy.manipulatedVertices[i].projectedVector = ProjectVector vertexVector, normal

      puts "Projected Vector: #{faceCuttingStrategy.manipulatedVertices[i].projectedVector.to_s}" if $debugOuterVertices

      # Get the angle between the rotated normal vector and the projected vector - Should be 0 or PI
      projectedAngle = normal.angle_between(faceCuttingStrategy.manipulatedVertices[i].projectedVector)
      puts "Projected Vector angle between normal: #{projectedAngle}" if $debugOuterVertices

      # Get the relative length of the projected vector from the origin - The projected value
      projectedLength = faceCuttingStrategy.manipulatedVertices[i].projectedVector.length

      # If the projected angle is PI, then assign the value to negative
      if projectedAngle < 1
        projectedLength = projectedLength * -1
      end

      # Save the projectedValue in the vertex
      faceCuttingStrategy.manipulatedVertices[i].projectedValue = projectedLength

    end

    # Take the length of these vector and sort them, including the origin which is zero
    faceCuttingStrategy.manipulatedVertices.sort! { |xP,yP| xP.projectedValue <=> yP.projectedValue }

    puts "Highest projectedValue: #{faceCuttingStrategy.manipulatedVertices.first.projectedValue}" if $debugOuterVertices
    puts "Lowest projectedValue: #{faceCuttingStrategy.manipulatedVertices.last.projectedValue}" if $debugOuterVertices

    # Save the references to the original vertices
    faceCuttingStrategy.outerVertices[0] = faceCuttingStrategy.manipulatedVertices.first.origVertex
    faceCuttingStrategy.outerVertices[1] = faceCuttingStrategy.manipulatedVertices.last.origVertex

    puts "Outer most side vertex A: #{faceCuttingStrategy.outerMostSideVertexA.position.to_s}" if $debugOuterVertices
    puts "Outer most side vertex B: #{faceCuttingStrategy.outerMostSideVertexB.position.to_s}" if $debugOuterVertices

    # Draw edges to show the outer vertices
    $entities.add_edges Geom::Point3d.new(0,0,0), Geom::Point3d.new(faceCuttingStrategy.outerVertices[0].position.to_a) if $debugOuterVertices
    $entities.add_edges Geom::Point3d.new(0,0,0), Geom::Point3d.new(faceCuttingStrategy.outerVertices[1].position.to_a) if $debugOuterVertices

  end

  def self.GenerateCuttingLine point, vector

    # Generate a line or actual two point that represent the cutting ray through the entire laser cutter

    # Length from bottom (Negative because it has to go to the bottom later)
    zBottomDiff = -point.z

    # Length from the table top
    zTopDiff = $tableHeight - point.z

    # Vector to top and bottom, used for projection
    vectorToBottom = Geom::Vector3d.new(0, 0, zBottomDiff)
    vectorToTop = Geom::Vector3d.new(0, 0, zTopDiff)

    DrawLine point, vectorToBottom, $entities if $debugGenerateCuttingLine
    DrawLine point, vectorToTop, $entities if $debugGenerateCuttingLine

    # Project vector to
    vectorToBottom = ProjectVector vectorToBottom, vector
    vectorToTop = ProjectVector vectorToTop, vector

    # Extend the vector to match the z height of the vectors to reach all the way to the top or bottom
    vectorToBottom = ExtendVector vectorToBottom, 'z', zBottomDiff
    vectorToTop = ExtendVector vectorToTop, 'z', zTopDiff

    # Move the point to the input point, making it absolute points from relative
    bottomPoint = point + vectorToBottom.to_a
    topPoint = point + vectorToTop.to_a

    puts "Top Point: #{topPoint}" if $debugGenerateCuttingLine
    puts "Bottom Point: #{bottomPoint}" if $debugGenerateCuttingLine

    DrawLine point, vectorToBottom, $entities if $debugGenerateCuttingLine
    DrawLine point, vectorToTop, $entities if $debugGenerateCuttingLine

    $entities.add_line bottomPoint, topPoint if $debugGenerateCuttingLine

    puts "#{vectorToBottom}" if $debugGenerateCuttingLine
    puts "#{vectorToTop}" if $debugGenerateCuttingLine

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

    # Variables need to be set as they might not be initialized if no second line test go through
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

        puts "This is: #{edge}" if $debugStrategy2

        # Check if the edge is on the face
        next unless edge.used_by?(faceCuttingStrategy.face)

        # Calculate the angle of the edge
        angle = edge.line[1].angle_between(Geom::Vector3d.new(0,0,1))

        puts "Edge Angle: #{angle * (180 / Math::PI) }. Less than: #{ (Math::PI / 4) * (180 / Math::PI) } or higher then: #{ 3 * Math::PI / 4 * (180 / Math::PI) }" if $debugStrategy2

        # Check if the edge is more that 45 degress and less than 135
        next if angle > Math::PI / 4 && angle < 3 * Math::PI / 4

        puts "Angle is alright" if $debugStrategy2

        # Get the vector from the edge
        vector = edge.line[1]

        puts "Vector of line: #{vector.to_s}" if $debugStrategy2

        break

      end

      # Get point and vector for cutting line
      # Position from outerVertex
      pointA = outerVertex.position

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

        faceCuttingStrategy.manipulatedVertices.each { |manipulatedVertex| puts "All: #{manipulatedVertex.projectedValue}"}
        puts "Highest: #{faceCuttingStrategy.manipulatedVertices.last.projectedValue}"

      end

      pointB = faceCuttingStrategy.manipulatedVertices.last.origVertex.position

      # Generate cutting line from the vertex and vector from the first edge
      tempRayB = CalculateCuttingStrategy.GenerateCuttingLine pointB, vector

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

  end



  def self.ThirdStrategy faceCuttingStrategy, cutting_index

    # As they are already saved from above (Second Strategy) they should just be checked.

    puts "Trying third strategy" if $debugStrategy3

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

      puts "Face #{cutting_index}. Strategy 3 was successful!" if $debugStrategy3

      # Success!
      return true

    end

    puts "Face #{cutting_index}. Strategy 3 was not successful, proceeding..." if $debugStrategy3

    # Failed!
    return false

  end

  def self.ExtendVector vector, xyz, value

    # Extend a vector from either x, y or z axis to meet the value

    # Calculate by how much it must be scaled (scalar)
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

    # Scale it by the scalar
    vector = ScaleVector vector, scalar

    return vector

  end



  def self.ScaleVector vector, scalar

    puts "Scalar before: #{scalar}" if $debugScaleVector

    # Make sure the scalar is positive, so it does not scale negatively
    scalar = scalar.abs

    puts "Scalar after: #{scalar}" if $debugScaleVector

    # Multiply x, y and z by the scalar
    vector.x = vector.x * scalar
    vector.y = vector.y * scalar
    vector.z = vector.z * scalar

    return vector

  end

  def self.RayTest ray, face

    puts "Testing ray..." if $debugRaytest

    # Array to hide entities hit, but are not an issue
    hiddenArray = Array.new()

    # Vector to represent the array from entry and exit point
    vector = Geom::Vector3d.new(ray[1] - ray[0])

    # Entry point
    point = ray[0]

    # Ray (SketchUp definition)
    ray = [point, vector]

    # Set hit to true already
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

      # Something is hit, get the point and entity
      foundPoint = entity[0]
      foundEntity = entity[1].first

      puts "We hit something!" if $debugRaytest
      puts "#{entity}" if $debugRaytest
      puts "#{foundEntity.vertices}" if $debugRaytest

      # --- Vertex Check ---

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

      # Check each if the point is inside the 2D polygon with the function from SketchUp API
      xyHit = Geom.point_in_polygon_2D(xyPoint, xyPolygon, true)
      yzHit = Geom.point_in_polygon_2D(yzPoint, yzPolygon, true)
      xzHit = Geom.point_in_polygon_2D(xzPoint, xzPolygon, true)

      puts "xyHit hit" if xyHit if $debug2DInsidePolygon
      puts "yzHit hit" if yzHit if $debug2DInsidePolygon
      puts "xzHit hit" if xzHit if $debug2DInsidePolygon

      # If the point is outside one of the 2D polygon it should be outside the face and break the loop, as something else is found
      if !xyHit || !yzHit || !xzHit

        puts "Object hit is outside the face!" if $debugRaytest

        # Unhide all hidden faces
        hiddenArray.each { |hiddenEntity| hiddenEntity.hidden = false }

        puts "Ray test complete!" if $debugRaytest

        hit = true

      else

        hit = false

      end

      # --- Test if the object is a face and it is parallel to cuttingFace

      if hit

        puts "Testing is the object is a plane with a normal parallel to the normal of the face." if $debugRaytest

        # Test if the entity is a face and it is parallel to the face
        if foundEntity.normal.parallel?(face.normal)

          puts "Face is parallel to the hit face." if $debugRaytest

          # Entity is not a problem
          hit = false

        else

          # Unhide all hidden faces
          hiddenArray.each { |hiddenEntity| hiddenEntity.hidden = false }

          return true

        end

      end

      # --- Test if the object is is a face and it is parallel to the line

      if hit

        puts "Testing if the plane normal hit is perpendicular to the ray." if $debugRaytest

        # Test if the normal to the face it perpendicular to the ray
        if foundEntity.normal.perpendicular?(ray[1].normalize)

          puts "Hit face normal is perpendicular to the ray." if $debugRaytest

          # Entity is not a problem
          hit = false

        else

          # Unhide all hidden faces
          hiddenArray.each { |hiddenEntity| hiddenEntity.hidden = false }

          return true

        end

      end

      # --- Hide the found object and continue the ray testing ---

      puts "Object hit is inside the face, hide it and try to shoot again..." if $debugRaytest

      # Hide the face/edge and repeat
      foundEntity.hidden = true

      # Remember the hidden item
      hiddenArray.push(foundEntity)

      # Even though nothing important was hit, still have to continue the ray testing
      hit = true

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

    puts "Projecting Vector A: #{vectorA.to_s} onto Vector B: #{vectorB.to_s}" if $debugProjectVector

    # Get a scalar to time a unit vector
    scalar = ( vectorA % vectorB ) / vectorB.length ** 2

    puts "Scalar: #{scalar}" if $debugProjectVector

    # Scale the vector
    vector = Geom::Vector3d.new(vectorB.x * scalar, vectorB.y * scalar, vectorB.z * scalar)

    puts "Result: #{vector.to_s}" if $debugProjectVector

    return vector

  end

  def self.UpVector faceCuttingStrategy

    # Generate a vector that is perpendicular to the face normal and facing up along the face

    # Normal of the face
    parallelvector = faceCuttingStrategy.face.normal

    # Set the z value to be 0, then the vector is pointing out from face in xy plane
    parallelvector.z = 0

    # Rotate the vector by pi/2, then it becomes parallel to the face
    x = parallelvector.x
    y = parallelvector.y

    parallelvector.x = -y
    parallelvector.y = x

    # Take the cross product from the parallel vector and the face normal vector, this gives the upvector
    vector = faceCuttingStrategy.face.normal * parallelvector

    vector.length = 10

    puts "Up Vector: #{vector}" if $debugUpVector

    point = Geom::Point3d.new(faceCuttingStrategy.outerVertices[1].position.to_a) if $debugUpVector

    DrawLine point, vector, $entities if $debugUpVector

    pointA = Geom::Point3d.new(faceCuttingStrategy.outerVertices[1].position.to_a) if $debugUpVector
    pointB = Geom::Point3d.new(faceCuttingStrategy.outerVertices[1].position.to_a) + vector.to_a if $debugUpVector

    $entities.add_edges pointA, pointB if $debugUpVector

    return vector

  end

  def self.DrawLine point, vector, entities

    # Function to draw a line from a vector and point instead of between two points

    pointA = point
    pointB = point + vector.to_a

    entities.add_line pointA, pointB

  end

  def self.LaserCut faceCuttingStrategy

    # Find the z-value based top-point, bottom-point and percentage
    # 0% being the top, 100% being the bottom

    # z of the top vertex
    topZ = faceCuttingStrategy.topVertex.position.z

    # z of the bottom vertex
    bottomZ = faceCuttingStrategy.bottomVertex.position.z

    # z height of the face
    z = topZ - bottomZ

    # Vector z-value
    z = (z / 100) * (100 - $laserFocalPercent)

    puts "z: #{z}" if $debugLaserCut

    # Create two vector based on the rays (bottom to top of the laser cutter)
    vectorA = Geom::Vector3d.new(faceCuttingStrategy.rays[0][0] - faceCuttingStrategy.rays[0][1])
    vectorB = Geom::Vector3d.new(faceCuttingStrategy.rays[1][0] - faceCuttingStrategy.rays[1][1])

    # If z is zero, do not extend as the scalar will be dividing with zero
    unless z == 0
      # Extend or in this case reduce the length of the vector to match the 100% the height of the face
      bottomRayA = ExtendVector vectorA, "z", z
      bottomRayB = ExtendVector vectorB, "z", z
    else
      # If the height is 0, meaning the wanted focal point is in the bottom of the
      # face, then the bottom ray is a zero vector
      bottomRayA = bottomRayB = Geom::Vector3d.new(0,0,0)
    end

    # Generate the vectors from the focal point to the laser origin, the place where all the axis can turn
    topRayA = ScaleVector vectorA.normalize, $laserFocalPoint
    topRayB = ScaleVector vectorB.normalize, $laserFocalPoint

    if $testPrintingWithoutZaxis

      topRayA = ExtendVector topRayA, "z", $laserFocalPoint
      topRayB = ExtendVector topRayB, "z", $laserFocalPoint

    end

    # The laser actual laser rays are exit point of the cut, bottom and top rays
    faceCuttingStrategy.laserStartPosition = faceCuttingStrategy.rays[0][1] + bottomRayA + topRayA
    faceCuttingStrategy.laserEndPosition = faceCuttingStrategy.rays[1][1] + bottomRayB + topRayB

  end

  def self.CalculateOrientation faceCuttingStrategy

    # Generate a vector from the laser ray
    vectorA = Geom::Vector3d.new(faceCuttingStrategy.rays[0][0] - faceCuttingStrategy.rays[0][1])
    vectorB = Geom::Vector3d.new(faceCuttingStrategy.rays[1][0] - faceCuttingStrategy.rays[1][1])

    # Calculate the A and B angles
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
