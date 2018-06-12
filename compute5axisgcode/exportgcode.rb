require 'sketchup.rb'

module ExportGCode

  def self.NameFile

    puts "#{Time.now.getutc}"

    filename = "GCODE #{Time.now.getutc.gcode}"

    return filename

  end

  def self.OpenFile file

    file = File.new(filename, "w")

  end

  def self.WriteGCodes file



=begin
    $gcodeArray.each do |gcode|

      file.puts(gcode.string)

    end
=end

  end

  def self.CloseFile file

    file.close



  end

end
