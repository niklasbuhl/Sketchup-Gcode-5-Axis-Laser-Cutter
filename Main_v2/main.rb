# Project by Jesper Kirial and Niklas Buhl

# Too add to Sketchup on Niklas

  # UI.menu.add_item("G-Code") { load("/Users/nbxyz/Develop/Sketchup-Gcode-5-Axis-Laser-Cutter/Main_v2/main.rb");}

# Too add to Sketchup on Jesper

# Z is the up axis

require 'sketchup'
# require 'os' # https://rubygems.org/gems/os // How to add it into the Skethcup path

require_relative 'analysemodel'
require_relative 'analysefaces'
require_relative 'analysecuttingfaces'
require_relative 'settings'

module Main

  # Hello World

  puts "Hello World. v0.3 - UpdateExtension working on mac"

  # Includes

  include AnalyseModel
  include AnalyseFaces
  include AnalyseCuttingFaces

  # Model and Layers

  $model
  $entities
  $layers

  # Face Arrays

  $faceArray = Array.new # Keep track of found faces
  $cuttingArray = Array.new # Keep track of the faces to be cut
  $analysedArray = Array.new # Keep the CuttingFace class in array

  # Primary Methods

  # ---

  def self.main_method

    puts "Hello Main Method"

  end

  def self.AnalyseModel

    puts "Analysing model..."

    $model = Sketchup.active_model
    $entities = $model.active_entities
    $layers = $model.layers

    puts "Finding faces..."

    foundFacesCount = 0

    # Clear faceArray and cuttingArray
    $faceArray.clear
    $cuttingArray.clear

    # Analyse model for faces

    AnalyseModel.FindFaces $model.entities, foundFacesCount, $faceArray

    # Color found faces green

    AnalyseModel.FoundFaces $faceArray

    puts "Faces #{$faceArray.count} found!"

    puts "Model analysed!"

  end

  def self.AnalyseFaces

    puts "Analysing faces..."

    $faceArray.each do |face|

      # Check for top and bottom
      next if AnalyseFaces.TopBottom face

      # Check for faces with too many vertices
      next if AnalyseFaces.TooManyVertices face

      # Check if faces is too angled
      next if AnalyseFaces.TooAngled face

      # Rest of faces is cutting faces
      AnalyseFaces.CutThisFace face, $cuttingArray # Function to color remaining red and put them into cutting faces array

    end

    puts "Analysed found faces!"

    puts "#{$cuttingArray.count} faces to cut!"

    puts "Faces Analysed!"

  end

  def self.AnalyseCuttingFaces

    puts "Analysing cutting faces..."

    # Clear analysedArray
    $analysedArray.clear

    new_layer = $layers.add "Analysing Layer"

    # Analyse each face
    $cuttingArray.each do |cuttingFace|

      thisCuttingFace = CuttingFace.new cuttingFace

      # Analyse top and bottom vertices
      AnalyseCuttingFaces.TopBottomZ thisCuttingFace

      # Analysing angle offset
      AnalyseCuttingFaces.XYAngleOffset thisCuttingFace

      # Analysing most side vertices
      AnalyseCuttingFaces.SideVertices thisCuttingFace

      # Edges available as start/end cutting vectors
      AnalyseCuttingFaces.AvailableCuttingEdges thisCuttingFace

      # Find a vector parallel to the plane in rectangular to the normal vector upwards
      AnalyseCuttingFaces.PlaneVector thisCuttingFace

      $analysedArray.push(thisCuttingFace)

    end

    puts "#{$analysedArray.count} cutting faces analysed!"

  end

  def self.CalculateCuttingStrategy

    puts "Calculating cutting strategy..."

    # Test cutting strategy 1

    # Test cutting strategy 2A

    # Test cutting strategy 2B

    # Test cutting strategy 3

    puts "Cutting strategy calculated!"

  end

  def self.CalculateTrajectory

    puts "Calculating Trajectory..."

    # Calculate shortest path between vectors

    puts "Trajectory Calculated!"

  end

  def self.GenerateGCode

    puts "Generating GCode..."

  end

  def self.ExportGCode

    puts "Export GCode..."

  end

  # ---

  # Developer Utilities

  # ---

  def self.GenerateTestModels

    puts "Generate Test Models. v0.2"

    model = Sketchup.active_model

    testModelPath = File.join(File.dirname(__FILE__),'/test-geometrier-laser.skp')

    model.import(testModelPath)

  end

  def self.GenerateSimpleTestModel

    puts "Generate Simple Test Model. v0.1"

    model = Sketchup.active_model

    testModelPath = File.join(File.dirname(__FILE__),'/test-simplemodel.skp')

    model.import(testModelPath)

  end

  def self.UpdateExtensionOSX

    puts "Updating modules. v1.0"

    projectdir = File.dirname(__FILE__)

    load projectdir + "/settings.rb"
    load projectdir + "/analysemodel.rb"
    load projectdir + "/analysefaces.rb"
    load projectdir + "/analysecuttingfaces.rb"

    # puts projectdir

  end

  # ---

  # User Interface Dropdown Menu

  # ---

  unless file_loaded?(__FILE__)

    menu = UI.menu('Plugins')

    menu.add_item('Analyse Model') {self.AnalyseModel}
    menu.add_item('Analyse Faces') {self.AnalyseFaces}
    menu.add_item('Analyse Cutting Faces') {self.AnalyseCuttingFaces}
    menu.add_item('Calculate Cutting Strategy') {self.CalculateCuttingStrategy}
    menu.add_item('Calculate Cutting Trajectory') {self.CalculateCuttingTrajectory}
    menu.add_item('Generate GCode') {self.GenerateGCode}
    menu.add_item('Export GCode') {self.ExportGCode}

    # Remove everything and generate test models (Used for development purposes)
    menu.add_item('Generate Test Models') {self.GenerateTestModels}
    menu.add_item('Generate Simple Test Model') {self.GenerateSimpleTestModel}

    # To remove extension (Used for development purposes)
    menu.add_item('Update Extension') {self.UpdateExtensionOSX}

    file_loaded(__FILE__)

  end

  # ---

  # User Interface Toolbar

  # ---

  # Create new toolbar with buttons.

=begin
  toolbar = UI::Toolbar.new "5 Axis Lasercutter"

  cmd = UI::Command.new("Analyse Model") { AnalyseModel }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Analyse Cutting Faces") { AnalyseCuttingFaces }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Calculate Cutting Strategy") { CalculateCuttingStrategy }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Generate GCode") { GenerateGCode }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Export GCode") { ExportGCode }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Generate Test Models") { GenerateTestModels }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Update Extension") { UpdateExtension }
  toolbar.add_item cmd

  toolbar.show

  toolbar.each { | item |
    puts item
  }
=end

end
