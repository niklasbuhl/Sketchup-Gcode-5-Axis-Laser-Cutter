require 'sketchup.rb'


# Direction class to keep track of rotation, this is not orientation as it does not keep track of rotation around it's own axis.
class Direction

  puts "Direction 1.3"

  attr_accessor :a, :b, :x, :y, :z

  def initialize

    @a = 0, @b = 0, @x = 0, @y = 0, @z = 0

  end

  def down

    @a = 0, @b = 0, @x = 0, @y = -1, @z = 0

  end

  def rotateAB ab # input vector

  end

  def rotateA a # input angle

    # Rotate the diection around the z-axis

  end

  def rotateB b # input angle

    # Rotate the direction around the x-axis

  end

  def angleAB direction #input direction

    # Return an array with the respective rotation around a and b given a new direction.

    ab = [a,b] # Output array with angles

  end

  def angle direction



    angle # Output angle in degress

  end

end

class Position

  puts "Position 1.3"

  attr_accessor :x, :y, :z

  def initialize vector

    @x = (vector[0].to_f).mm
    @y = (vector[1].to_f).mm
    @z = (vector[2].to_f).mm

    puts "New position: #{x}, #{y}, #{z}"

  end

  def print

    puts "x: #{x}, y: #{y}, z: #{z}"

  end

  def translate input

    case input

    when Vector

      #puts "Translating with vector."

      puts "Translation: #{input[0]}, #{input[1]}, #{input[2]}"



      puts "New Position: #{x}, #{y}, #{z}"

    else

      puts "Translating with other."

    end

  end

  def vector

    Vector[x,y,z]

  end

end
