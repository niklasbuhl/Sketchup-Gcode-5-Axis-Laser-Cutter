<<<<<<< HEAD

=======
>>>>>>> parent of 987e53f... 14.05
# Project by Jesper Kirial and Niklas Buhl

# Too add to Sketchup on Niklas

  # UI.menu.add_item("Reload My File") { load("/Users/nbxyz/Develop/Sketchup-Gcode-5-Axis-Laser-Cutter/Main_v2/main.rb");}

# Too add to Sketchup on Jesper

<<<<<<< HEAD
  # UI.menu.add_item("5-Axis reload") { load("C:\\Projects\\5axis\\Sketchup-Gcode-5-Axis-Laser-Cutter\\Main_v2\\main.rb");}

=======
  # UI.menu.add_item("5-Axis") { load("C:\\Projects\\5axis\\Sketchup-Gcode-5-Axis-Laser-Cutter\\Main_v2\\main.rb");}

  # main_method() 

# Z is the up axis
>>>>>>> parent of 987e53f... 14.05

require 'sketchup'
# require 'os' # https://rubygems.org/gems/os // How to add it into the Skethcup path

<<<<<<< HEAD
require_relative 'modelfaces'
require_relative 'analysefaces'
require_relative 'analysecuttingfaces'
=======
require_relative 'analysemodel'
require_relative 'analysefaces'
require_relative 'analysecuttingfaces'
require_relative 'settings'
>>>>>>> parent of 987e53f... 14.05

module Main

  # Hello World

  puts "Hello World. v0.3 - UpdateExtension working on mac"

  # Includes

<<<<<<< HEAD
  include ModelFaces
  include AnalyseFaces
  include AnalyseCuttingFaces
  include AnalyseCuttingFaces
=======
  include AnalyseModel
  include AnalyseFaces
  include AnalyseCuttingFaces
>>>>>>> parent of 987e53f... 14.05

  # Model and Layers

  $model
  $layers

<<<<<<< HEAD
  
  # Variables

  $faceArray = Array.new # Keep track of found faces

  # ---
=======
  # Face Arrays

  $faceArray = Array.new # Keep track of found faces
  $cuttingArray = Array.new # Keep track of the faces to be cut
  $analysedArray = Array.new # Keep the CuttingFace class in array
>>>>>>> parent of 987e53f... 14.05

  # Primary Methods

  # ---

<<<<<<< HEAD
=======
  def self.main_method

    puts "Hello Main Method"

  end

>>>>>>> parent of 987e53f... 14.05
  def self.AnalyseModel

    puts "Analysing model..."

    $model = Sketchup.active_model
    $layers = $model.layers

    puts "Finding faces..."

    foundFacesCount = 0

<<<<<<< HEAD
    # Analyse model for faces

    ModelFaces.FaceCheck Sketchup.active_model.entities, foundFacesCount, $faceArray

    # Color found faces green

    ModelFaces.FoundFaces $faceArray

    puts "Faces found!"

    puts "Analysing found faces..."
=======
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
>>>>>>> parent of 987e53f... 14.05

    $faceArray.each do |face|

      # Check for top and bottom
      next if AnalyseFaces.TopBottom face

      # Check for faces with too many vertices
      next if AnalyseFaces.TooManyVertices face

      # Check if faces is too angled
      next if AnalyseFaces.TooAngled face

      # Rest of faces is cutting faces
<<<<<<< HEAD
      #function to color remaining red and put them into cutting faces array
=======
      AnalyseFaces.CutThisFace face, $cuttingArray # Function to color remaining red and put them into cutting faces array
>>>>>>> parent of 987e53f... 14.05

    end

    puts "Analysed found faces!"

<<<<<<< HEAD
    puts "Model Analysed!"
=======
    puts "#{$cuttingArray.count} faces to cut!"

    puts "Faces Analysed!"
>>>>>>> parent of 987e53f... 14.05

  end

  def self.AnalyseCuttingFaces

    puts "Analysing cutting faces..."

<<<<<<< HEAD
    # Analyse each face

    puts "Cutting faces analysed!"
=======
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
      AnalyseCutting.FacesPlaneVector thisCuttingFace

      $analysedArray.push(thisCuttingFace)

    end

    puts "#{$analysedArray.count} cutting faces analysed!"
>>>>>>> parent of 987e53f... 14.05

  end

  def self.CalculateCuttingStrategy

    puts "Calculating cutting strategy..."

<<<<<<< HEAD
    # Optimize each cutting faces

    # Optimize cutting and moving path
=======
    # Test cutting strategy 1

    # Test cutting strategy 2A

    # Test cutting strategy 2B

    # Test cutting strategy 3
>>>>>>> parent of 987e53f... 14.05

    puts "Cutting strategy calculated!"

  end

<<<<<<< HEAD
=======
  def self.CalculateTrajectory

    puts "Calculating Trajectory..."

    # Calculate shortest path between vectors

    puts "Trajectory Calculated!"

  end

>>>>>>> parent of 987e53f... 14.05
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

<<<<<<< HEAD
=======
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

>>>>>>> parent of 987e53f... 14.05
  end

  def self.UpdateExtensionOSX

    puts "Updating modules. v0.6 - OSX"

    projectdir = File.dirname(__FILE__)

<<<<<<< HEAD
    load projectdir + "/modelfaces.rb"
=======
    load projectdir + "/settings.rb"
    load projectdir + "/analysemodel.rb"
>>>>>>> parent of 987e53f... 14.05
    load projectdir + "/analysefaces.rb"
    load projectdir + "/analysecuttingfaces.rb"

    # puts projectdir

  end

  def self.UpdateExtensionWIN

    puts "Updating modules. v0.1 - WIN"

    projectdir = File.dirname(__FILE__)

<<<<<<< HEAD
    load projectdir + "\modelfaces.rb"
    load projectdir + "\analysefaces.rb"
    load projectdir + "\analysecuttingfaces.rb"
=======
    load projectdir + "/settings.rb"
    load projectdir + "/analysemodel.rb"
    load projectdir + "/analysefaces.rb"
    load projectdir + "/analysecuttingfaces.rb"
>>>>>>> parent of 987e53f... 14.05

    # puts projectdir

  end

  # ---

  # User Interface Dropdown Menu

  # ---

  unless file_loaded?(__FILE__)

    menu = UI.menu('Plugins')

    menu.add_item('Analyse Model') {self.AnalyseModel}
<<<<<<< HEAD
    menu.add_item('Analyse Cutting Faces') {self.AnalyseCuttingFaces}
    menu.add_item('Calculate Cutting Strategy') {self.CalculateCuttingStrategy}
=======
    menu.add_item('Analyse Faces') {self.AnalyseFaces}
    menu.add_item('Analyse Cutting Faces') {self.AnalyseCuttingFaces}
    menu.add_item('Calculate Cutting Strategy') {self.CalculateCuttingStrategy}
    menu.add_item('Calculate Cutting Trajectory') {self.CalculateCuttingTrajectory}
>>>>>>> parent of 987e53f... 14.05
    menu.add_item('Generate GCode') {self.GenerateGCode}
    menu.add_item('Export GCode') {self.ExportGCode}

    # Remove everything and generate test models (Used for development purposes)
    menu.add_item('Generate Test Models') {self.GenerateTestModels}
<<<<<<< HEAD
=======
    menu.add_item('Generate Simple Test Model') {self.GenerateSimpleTestModel}
>>>>>>> parent of 987e53f... 14.05

    # To remove extension (Used for development purposes)
    menu.add_item('Update Extension OSX') {self.UpdateExtensionOSX}
    menu.add_item('Update Extension WIN') {self.UpdateExtensionWIN}

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
