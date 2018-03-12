require 'sketchup.rb'
require 'extensions.rb'

module NiklasBuhl
  module HelloCube
    unless file_loaded?(__FILE__)

      ex SketchupExtension.new('Hello Cube', 'Cube/main')

      ex.description = 'Sketchup Hello Cube'
      ex.version = '1.0.0'
      ex.copyright = 'Team Raket @ 2018'
      ex.creator = 'Niklas Buhl'

      Sketchup.register_extension(ex, true)

      file_loaded(__FILE__)

    end
  end
end