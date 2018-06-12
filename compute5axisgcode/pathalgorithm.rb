# Project by Jesper Kirial and Niklas Buhl

class GCode

  attr_accessor :point1, :point2, :orientation1, :orientation2, :placed, :start_point, :gcode, :x, :y, :z, :a, :b, :feedrate, :power, :distance, :string

  def initialize(point1, point2, orientation1, orientation2, gcode)
    #def initialize(point1, point2, gcode, orientation1, orientation2)

    @point1 = Geom::Point3d.new(point1)
    @point2 = Geom::Point3d.new(point2)
    @gcode = gcode

    @orientation1 = orientation1
    @orientation2 = orientation2

    @a = 0
    @b = 0

    @distance = 0
    @start_point = 1

    @feedrate = $laserFeedrate
    @power = $laserIntensity

    @string = nil

    puts "#{@point1} -> #{@point2} -> #{@gcode}" if $debugGCode

  end

end

module CalculateTrajectory

  def self.DrawGCodes

    puts "Drawing #{$gcodeArray.size} GCodes." if $debugGCode

    $gcodeArray.each_with_index do |gcode,index|

      puts "GCode #{index}[#{gcode.gcode}]: Abs1: #{gcode.point1.x}, #{gcode.point1.y}, #{gcode.point1.y}, #{gcode.orientation1[0]}, #{gcode.orientation1[1]}" if $debugGCodeDraw
      puts "GCode #{index}[#{gcode.gcode}]: Abs2: #{gcode.point2.x}, #{gcode.point2.y}, #{gcode.point2.y}, #{gcode.orientation2[0]}, #{gcode.orientation2[1]}" if $debugGCodeDraw
      puts "GCode #{index}[#{gcode.gcode}]: Rela: #{gcode.x}, #{gcode.y}, #{gcode.y}, #{gcode.a}, #{gcode.b}" if $debugGCodeDraw

      $laserCutArray.push($entities.add_line gcode.point1, gcode.point2)

    end

  end

  def self.RelativeGCodeRelativeXYZ gcode

    puts "Point1: #{gcode.point1}" if $debugGCodeRelative
    puts "Point2: #{gcode.point2}" if $debugGCodeRelative

    #gcode.x = (gcode.point2.x * (-1)  - gcode.point1.x * (-1) )
    #gcode.y = (gcode.point2.y * (-1)  - gcode.point1.y * (-1) )
    #gcode.z = (gcode.point2.z * (-1)  - gcode.point1.z * (-1) )

    gcode.x = gcode.point2.x  - gcode.point1.x
    gcode.y = gcode.point2.y  - gcode.point1.y
    gcode.z = gcode.point2.z  - gcode.point1.z

    puts "OrienationCalc: #{gcode.orientation1[0]} - #{gcode.orientation2[0]}" if $debugGCodeAngle
    puts "OrienationCalc: #{gcode.orientation1[1]} - #{gcode.orientation2[1]}" if $debugGCodeAngle


    # Maybe reserving will do the trick
    #gcode.a = (gcode.orientation1[0] * (-1) - gcode.orientation2[0] * (-1))
    #gcode.b = (gcode.orientation1[1] * (-1) - gcode.orientation2[1] * (-1))

    gcode.a = gcode.orientation1[0] - gcode.orientation2[0]
    gcode.b = gcode.orientation1[1] - gcode.orientation2[1]

    gcode.a = gcode.a * (-1) if $invertAngleA
    gcode.b = gcode.b * (-1) if $invertAngleB

    puts "OrienationResu: #{gcode.a}" if $debugGCodeAngle
    puts "OrienationResu: #{gcode.b}" if $debugGCodeAngle

    # For some reason when doing  algebraic the numbers
    gcode.x = gcode.x.to_mm
    gcode.y = gcode.y.to_mm
    gcode.z = gcode.z.to_mm

    # Convert to float so it can be rounded.
    gcode.x = gcode.x.to_f
    gcode.y = gcode.y.to_f
    gcode.z = gcode.z.to_f

    x = gcode.x = gcode.x.round($gcodeDecimals)
    y = gcode.y = gcode.y.round($gcodeDecimals)
    z = gcode.z = gcode.z.round($gcodeDecimals)

    a = gcode.a = gcode.a.round($gcodeDecimals)
    b = gcode.b = gcode.b.round($gcodeDecimals)

    return false if x == 0 && y == 0 && z == 0 && a == 0 && b == 0

    puts "Relative GCode: #{gcode.x}, #{gcode.y}, #{gcode.z}" if $debugGCodeRelative

    return true

  end

  def self.WriteGCodeString gcode

    # G0  [tab] X0.0000 [tab] Y0.0000 [tab] Z0.0000 [tab] A0.0000 [tab] B0.0000 [tab] F0.0000

    gcode.string = "G#{gcode.gcode}\t"

    gcode.string << "X#{(gcode.x)}\t"
    gcode.string << "Y#{(gcode.y)}\t"
    gcode.string << "Z#{(gcode.z)}\t"

    gcode.string << "A#{(gcode.a)}\t"
    gcode.string << "B#{(gcode.b)}\t"

    gcode.string << "F150" if gcode.gcode == 1
    gcode.string << "F400" if gcode.gcode == 0

    #gcode.string << "F#{(gcode.feedrate)}" # Removed tab
    #gcode.string << "P#{(gcode.power)}"

    puts "#{gcode.string}" if $debugFinalGCode

  end

  def self.CheckGCode gcode

    if (gcode.gcode == 0 || gcode.gcode == 1) && gcode.x == 0 && gcode.y == 0 && gcode.z == 0 && gcode.a == 0 && gcode.b == 0

      return true

    end

    return false

  end

  def self.GetCuts tempGCodeArray

    $cuttingStrategy.each do |faceCuttingStrategy|

      point1 = faceCuttingStrategy.laserStartPosition
      point2 = faceCuttingStrategy.laserEndPosition
      orientation1 = faceCuttingStrategy.laserStartOrientation
      orientation2 = faceCuttingStrategy.laserEndOrientation

      # New GCode with point1, point2 and the cutting code.
      gcode = GCode.new(point1, point2, orientation1, orientation2, 1)

      tempGCodeArray.push(gcode)

    end

  end

  def self.PathAlgorithm tempGCodeArray

    # Ghost GCode from start origin
    ghost_point = Geom::Point3d.new($laserStartX,$laserStartY,$laserStartZ)
    ghost_orientation = [0,0]

    ghost = GCode.new(ghost_point, ghost_point, ghost_orientation, ghost_orientation, 0)

    tempGCodeArray.insert(0,ghost)

    # If there's only one GCode cut instructions...

    # Cut'n'Move

    # Test first point
    $gcodeArray.push(tempGCodeArray.first)
    start_point = tempGCodeArray.first.point2
    tempGCodeArray.shift

    while tempGCodeArray.size > 0

      tempGCodeArray.each do |next_gcode|

        # Get the next entry point distance
        next_gcode.distance = start_point.distance(next_gcode.point1)

        # Get the next exit point distance
        other_distance = start_point.distance(next_gcode.point2)

        # If the exit point is closer
        if next_gcode.distance > other_distance

          puts "Exit is closest." if $debugPathAlgorithm

          # Swap exit and entry point and orientation
          point_temp = next_gcode.point2
          orientation_temp = next_gcode.orientation2

          next_gcode.point2 = next_gcode.point1
          next_gcode.orientation2 = next_gcode.orientation1

          next_gcode.point1 = point_temp
          next_gcode.orientation1 = orientation_temp

          # Save distance in next_gcode
          next_gcode.distance = other_distance

        end

        puts "Entry is closest." if $debugPathAlgorithm

      end

      # Sort array leftover array for distances
      tempGCodeArray.sort! { |xD,yD| xD.distance <=> yD.distance }

      # Move GCode between cutting gcodes
      movePtEntry = $gcodeArray.last.point2
      movePtExit = tempGCodeArray.first.point1
      moveOrEntry = $gcodeArray.last.orientation2
      moveOrExit = tempGCodeArray.first.orientation1
      moveGCode = GCode.new(movePtEntry, movePtExit, moveOrEntry, moveOrExit, 0)

      moveDifference = [moveGCode.orientation2[0] - moveGCode.orientation1[0], moveGCode.orientation2[1] - moveGCode.orientation1[1]]
      cutDifference = [tempGCodeArray.first.orientation2[0] - tempGCodeArray.first.orientation1[0], tempGCodeArray.first.orientation2[1] - tempGCodeArray.first.orientation1[1]]

      puts "MoveCode[#{$gcodeArray.size + 1}]: Entry: #{moveGCode.orientation1[0]}, #{moveGCode.orientation1[1]}. Exit: #{moveGCode.orientation2[0]}, #{moveGCode.orientation2[1]}, Difference: #{moveDifference[0]}, #{moveDifference[1]}" if $debugViften
      puts "CutCode[#{$gcodeArray.size + 2}]: Entry: #{tempGCodeArray.first.orientation1[0]}, #{tempGCodeArray.first.orientation1[1]}. Exit: #{tempGCodeArray.first.orientation2[0]}, #{tempGCodeArray.first.orientation2[1]}, Difference: #{cutDifference[0]}, #{cutDifference[1]}" if $debugViften

      # Push the moving gcode
      $gcodeArray.push(moveGCode)

      # Take first gcode (Closest)
      $gcodeArray.push(tempGCodeArray.first)

      # Save starting exit point
      start_point = tempGCodeArray.first.point2

      # Remove first gcode
      tempGCodeArray.shift

    end

    # Go back to 0,0,0,0,0
    finalGcode = GCode.new($gcodeArray.last.point2, ghost_point, $gcodeArray.last.orientation2, ghost_orientation,0)

    $gcodeArray.push(finalGcode)

=begin
    tempGCodeArray.each do |tempGCode|

      $gcodeArray.push(tempGCode)

    end
=end

=begin
    $gcodeArray.push(tempGCodeArray.first)

    limit = tempGCodeArray.size

    x = 0

    while x < limit

      x += 1

      tempGCodeArray.compact! # removes all NIL elements in array

      for j in tempGCodeArray do

        i = tempGCodeArray.first
        distance1 = 0
        distance2 = 0

        if j == i

        else

          travel_point1 = nil
          travel_point2 = nil

          if i.start_point == 2

              puts "starting point 2" if $debugCalculateTrajectory

              travel_point1 = i.point1
              orientation_point1 = i.orientation1

              distance1 = i.point1.distance(j.point1)

              Sketchup.active_model.entities.add_line(i.point1, j.point1) if $debugCalculateTrajectory

              distance2 = i.point1.distance(j.point2)

              Sketchup.active_model.entities.add_line(i.point1, j.point2) if $debugCalculateTrajectory

          else

              puts "starting point 1" if $debugCalculateTrajectory

              travel_point1 = i.point2
              orientation_point1 = i.orientation2

              distance1 = i.point2.distance(j.point1)

              Sketchup.active_model.entities.add_line(i.point2, j.point1) if $debugCalculateTrajectory

              distance2 = i.point2.distance(j.point2)

              Sketchup.active_model.entities.add_line(i.point2, j.point2) if $debugCalculateTrajectory

          end

          if distance1 <= distance2

              j.start_point = 1
              j.distance = distance1

              puts "Does this happen???"  if $debugCalculateTrajectory
              puts"distance1 ---->> #{distance1} < #{distance2}"  if $debugCalculateTrajectory

          else

              j.start_point = 2
              j.distance = distance2

              puts "Or this happen???"  if $debugCalculateTrajectory
              puts"distance2 ---->> #{distance2} < #{distance1}"  if $debugCalculateTrajectory

          end

        end

      end

      puts " #{distance2} || #{distance1}" if $debugCalculateTrajectory

      tempGCodeArray.shift                                               # Removed the tested index

      tempGCodeArray.sort! { |xD,yD| xD.distance <=> yD.distance }             # Sort the array according to the distance meassured

      puts "Size: #{tempGCodeArray.size}" if $debugCalculateTrajectory

      if tempGCodeArray.size != 0

        if tempGCodeArray.first.start_point == 1
          travel_point2 = tempGCodeArray.first.point1
          orientation_point2 = tempGCodeArray.first.orientation1

        else
          travel_point2 = tempGCodeArray.first.point2
          orientation_point2 = tempGCodeArray.first.orientation2

        end

      end

      movenode = GCode.new(travel_point1, travel_point2, orientation_point1, orientation_point2, 0)

      $gcodeArray.push(movenode)

      # Pushes the arranged lines to distance sorted array
      $gcodeArray.push(tempGCodeArray.first) if tempGCodeArray.size != 0

    end

=end

  end

end
