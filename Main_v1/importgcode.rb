require 'sketchup.rb'

require_relative 'gcodeclass.rb'

module ImportGCode

  def self.import_gcode array

    puts array

    puts "Select File..."

    filename = "na"

    # Select file with interface, allow files with .txt and .gcode
    filename = UI.openpanel("Select GCode file", "~", "Text Files|*.txt|GCode Files|*.gcode")


    # Check if a file is selected, if not - return
    unless filename
      puts "No file was chosen."
      return
    end

    # Open the file in (r)eading mode
    file = File.open(filename,"r");

    puts "Reading file..."

    # While it can read a new line
    while(temp = file.gets)

      # Read Line unless first character is '#' (comments)
      if temp.initial != '#'

        # Split the string by TABs
        x, y, z, a, b = temp.chomp.split("\t")

        # Read string and convert to float mm or angle
        x = (x.to_f).mm
        y = (y.to_f).mm
        z = (z.to_f).mm
        a = (a.to_f)
        b = (b.to_f)

        puts "x: #{x}, y: #{y}, z: #{z}, a: #{a}, b: #{b}."

        # Write the instruction to the global Array
        tempGCode = GCode.new

      end

    end

    # Read a tab-seperated lines

    # Print out all GCodes

    puts "GCode imported!"

  end
end
