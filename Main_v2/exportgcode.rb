require 'sketchup.rb'

require_relative 'assets.rb'

module ExportGCode

  puts "Export GCode 0.1" # Lots of puts

  # Draw complete GCode trajectory
  def self.draw array, position

    puts "Drawing the GCode instruction set..."

    # Begin figure
    model = Sketchup.active_model

    # Draw each GCode
    array.each do |gcode|

      # Draw each GCode and
      gcode.draw(position, model)

      # Update the global position
      position.translate(gcode.translation)


    end

    # End figure

  end

  def self.create_new_file

    puts "Creating new file..."

    puts "Name: ?"

    puts "New file created!"

  end

  def self.generate_gcode

    puts "Generating GCode from trajectory..."

    puts "Using syntax like a boss..."

    puts "Hai, done!"

  end

  def self.write_gcode_to_file

    puts "Write to file..."

    puts "Complete! Remember to eject properly."

    puts "Happy cutting!"

  end

end
