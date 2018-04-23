require 'sketchup.rb'
require 'matrix.rb'

require_relative 'assets.rb'

class GCode

  puts "GCode 1.1" # Data

  # The GCode object(class)

  # G G0(Move), G1(Cut), G??(Return to origin)
  # X translation in mm
  # Y translation in mm
  # Z translation in mm
  # A rotation in degrees
  # B rotation in degrees

  #Data = Struct.new(:g, :x1, :y1, :z1, :a1, :b1)

  # Starting position and orientation of the instruction
  #Position = Struct.new(:x0, :y0, :z0, :a0, :b0)

  attr_accessor :g, :x, :y, :z, :a, :b

  #def initialize opts
  def initialize(g, x, y, z, a, b)

    @g = g
    @x = x
    @y = y
    @z = z
    @a = a
    @b = b

    #@data = Data.new(opts[:g], opts[:x], opts[:y], opts[:z], opts[:a], opts[:b])

  end

  def draw position, model

    # array is the origin position and orientation

    ix = position.x
    iy = position.y
    iz = position.z

    ox = ix + x
    oy = iy + y
    oz = iz + z

    puts "Drawing GCode #{g} from #{ix}, #{iy}, #{iz} to #{ox}, #{oy}, #{oz}"

    #model.active_entities.add_edges([array[0],array[1],array[2],[x,y,z]])

  end

  def print

    puts "G: #{g}, X: #{x}, Y: #{y}, Z: #{z}, A: #{a}, B: #{b}"

  end

  def translation

    Vector[@x,@y,@z]

  end

  def rotation

    v = [a,b]

  end

end
