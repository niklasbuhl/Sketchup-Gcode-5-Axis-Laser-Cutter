# Project by Jesper Kirial and Niklas Buhl

class GCode

  # The GCode class to keep track of absolute,relative positions and orientations

  attr_accessor :point1, :point2, :orientation1, :orientation2, :placed, :gcode, :x, :y, :z, :a, :b, :feedrate, :power, :distance, :string

  def initialize(point1, point2, orientation1, orientation2, gcode)
    #def initialize(point1, point2, gcode, orientation1, orientation2)

    @point1 = Geom::Point3d.new(point1)
    @point2 = Geom::Point3d.new(point2)
    @gcode = gcode

    @orientation1 = orientation1
    @orientation2 = orientation2

    @a = 0
    @b = 0

    # Distance is a value used to sort the gcodes in order of distance to some point
    @distance = 0

    # Feed rate to the stepper motors
    @feedrate = 0
    @power = 0

    @string = nil

    puts "#{@point1} -> #{@point2} -> #{@gcode}" if $debugGCode

  end

end

module CalculateTrajectory

  def self.DrawGCodes

    # Draw the gcodes

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

    # Calculate the relative movement
    gcode.x = gcode.point2.x  - gcode.point1.x
    gcode.y = gcode.point2.y  - gcode.point1.y
    gcode.z = gcode.point2.z  - gcode.point1.z

    puts "OrienationCalc: #{gcode.orientation1[0]} - #{gcode.orientation2[0]}" if $debugGCodeAngle
    puts "OrienationCalc: #{gcode.orientation1[1]} - #{gcode.orientation2[1]}" if $debugGCodeAngle

    # Calculate the relative angle movement
    gcode.a = gcode.orientation1[0] - gcode.orientation2[0]
    gcode.b = gcode.orientation1[1] - gcode.orientation2[1]

    # Invert depending on the machine config
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

    # Save the relative in the gcode and in a variable
    x = gcode.x = gcode.x.round($gcodeDecimals)
    y = gcode.y = gcode.y.round($gcodeDecimals)
    z = gcode.z = gcode.z.round($gcodeDecimals)

    a = gcode.a = gcode.a.round($gcodeDecimals)
    b = gcode.b = gcode.b.round($gcodeDecimals)

    # If there is no movement, i.e. 0,0,0,0,0 then discard the gcode
    return false if x == 0 && y == 0 && z == 0 && a == 0 && b == 0

    puts "Relative GCode: #{gcode.x}, #{gcode.y}, #{gcode.z}" if $debugGCodeRelative

    return true

  end

  def self.WriteGCodeString gcode

    # G0  [tab] X0.0000 [tab] Y0.0000 [tab] Z0.0000 [tab] A0.0000 [tab] B0.0000 [tab] F0.0000

    # GCode convention for the Smoothieboard

    gcode.string = "G#{gcode.gcode}\t"

    gcode.string << "X#{(gcode.x)}\t"
    gcode.string << "Y#{(gcode.y)}\t"
    gcode.string << "Z#{(gcode.z)}\t"

    gcode.string << "A#{(gcode.a)}\t"
    gcode.string << "B#{(gcode.b)}\t"

    # The feedrate depends on many mechanical factors

    # If the machine is cutting, then it has to go slow
    gcode.string << "F#{$laserCuttingFeedrate}" if gcode.gcode == 1

    if gcode.gcode == 0

      if gcode.z != 0

        # If the movement is not moving in z-axis
        gcode.string << "F#{$laserZFeedrateLimit}"

      else

        # If the machine is only moving in x, y, a, b
        gcode.string << "F#{$laserFeedrate}"

      end

    end

    puts "#{gcode.string}" if $debugFinalGCode

  end

  def self.CheckGCode gcode

    # Check the gcode is it is needed, moving and cutting with 0,0,0,0,0 are not useful
    if (gcode.gcode == 0 || gcode.gcode == 1) && gcode.x == 0 && gcode.y == 0 && gcode.z == 0 && gcode.a == 0 && gcode.b == 0

      return true

    end

    return false

  end

  def self.GetCuts tempGCodeArray

    # Collect all the calculated cuts from the cutting strategy cutting array

    $cuttingStrategy.each do |faceCuttingStrategy|

      # Get start point
      point1 = faceCuttingStrategy.laserStartPosition

      # Get end point
      point2 = faceCuttingStrategy.laserEndPosition

      # Get start orientation
      orientation1 = faceCuttingStrategy.laserStartOrientation

      # Get end orientation
      orientation2 = faceCuttingStrategy.laserEndOrientation

      # New GCode with point1, point2 and the cutting code.
      gcode = GCode.new(point1, point2, orientation1, orientation2, 1)

      # Push to the array
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

    # --- The Great Cut'n'Move Algorithm ---

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

          # Save one point, orientation
          point_temp = next_gcode.point2
          orientation_temp = next_gcode.orientation2

          # Swap points, orientation
          next_gcode.point2 = next_gcode.point1
          next_gcode.orientation2 = next_gcode.orientation1

          # Insert saved points, orientation
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

  end

end
