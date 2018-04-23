require 'sketchup.rb'

require_relative 'gcodeclass.rb'

module ImportGCode

  #puts "Import GCode 1.2" # Working on setting up an GCode array
  puts "Import GCode 1.4" # Print GCode Array

  #include GCode

  def self.import_gcode array

    puts array

    puts "Select File..."

    filename = ""

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

      #puts "Reading line: #{temp}"

      # Read Line unless first character is '#' (comments)
      if temp.chars.first != '#'

        # Split the string by TABs
        g, x, y, z, a, b = temp.chomp.split("\t")

        # Read string and convert to float mm or angle
        g = g # G Code
        x = (x.to_f).mm # X translation
        y = (y.to_f).mm # Y translation
        z = (z.to_f).mm # Z translation
        a = (a.to_f) # A rotation
        b = (b.to_f) # B rotation

        #Print read GCode
        #puts "g: #{g}, x: #{x}, y: #{y}, z: #{z}, a: #{a}, b: #{b}."

        # Write the instruction to the global Array
        tempGCode = GCode.new(g, x, y, z, a, b)

        # Load data into GCode
        array.push(tempGCode)

      else

        puts "Comment detected. Discarding line."

      end

    end

    # Print out all GCodes
    array.each { |x| x.print}

    puts "GCode imported!"

  end
end
