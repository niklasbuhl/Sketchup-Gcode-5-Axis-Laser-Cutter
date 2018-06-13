=begin

# Project by Jesper Kirial and Niklas Buhl

# Too add to Sketchup on Niklas

  UI.menu.add_item("0. G-Code") { load("/Users/nbxyz/Develop/Sketchup-Gcode-5-Axis-Laser-Cutter/compute5axisgcode.rb");}

# Too add to Sketchup on Jesper

UI.menu.add_item("0. G-Code") { load("C:\\Projects\\Sketchup-Gcode-5-Axis-Laser-Cutter\\compute5axisgcode/.rb");}

# Test to add to Jacob Lawaetz

UI.menu.add_item("G-Code") {



  load("C:\\Projects\\Sketchup-Gcode-5-Axis-Laser-Cutter\\compute5axisgcode/.rb")

}


# Z is the up axis

=end

require 'sketchup'
# require 'os' # https://rubygems.org/gems/os // How to add it into the Skethcup path

require_relative 'compute5axisgcode/analysemodel.rb'
require_relative 'compute5axisgcode/analysefaces.rb'
#require_relative 'analysecuttingfaces'
#require_relative 'calculatecuttingstrategy'
require_relative 'compute5axisgcode/calculatecuttingstrategy.rb'
require_relative 'compute5axisgcode/exportgcode.rb'
require_relative 'compute5axisgcode/settings.rb'
require_relative 'compute5axisgcode/pathalgorithm.rb'

module Main

  # Hello World

  puts "Hello World. v2.7 - Initializing Prismatic Accelerator..."

  # Includes
  include AnalyseModel
  include AnalyseFaces
  include CalculateCuttingStrategy
  include CalculateTrajectory
  include ExportGCode

  # Model
  $model = Sketchup.active_model
  $entities = $model.active_entities

  # Entity Arrays
  $edgeArray = Array.new # Collect all edges
  $faceArray = Array.new # Keep track of found faces
  $vertexArray = Array.new # Keep track of all the vertices

  # Face Arrays
  $cuttingArray = Array.new # Keep track of the faces to be cut
  $cuttingStrategy = Array.new # Keep track of cutting strategies

  # Laser Arrays
  $laserCutArray = Array.new # For all the laser cutting lines
  $laserRayArray = Array.new # For all the ray

  # GCode Arrays
  $gcodeArray = Array.new # Keep track of the GCode

  # Program states
  $programState = 0

  # ---

  # --- Primary Methods ---

  # ---

  def self.main_method

    puts "Hello Main Method"

  end

  def self.AnalyseModel

    puts "Analysing model v1.1"

    t1 = Time.now

    # Updating all sketchup entities
    $model = Sketchup.active_model
    $entities = $model.active_entities
    #$layers = $model.layers

    # Layers
    #$originallayer = $layers.layer
    #$originallayer.name ="OriginalLayers"
    #$cuttingtestlayer = $layers.add("CuttingTestLayer")
    #$gcodelayer = $layers.add("GCodeLayer")

    # Clear faceArray and cuttingArray
    $faceArray.clear
    $edgeArray.clear
    $vertexArray.clear

    $cuttingArray.clear
    $cuttingStrategy.clear

    # Remove and clear the cuts and rays
    CalculateCuttingStrategy.ClearCutRay

    # Explode Model!
    AnalyseModel.Explode $model.entities

    # Find faces in the model
    AnalyseModel.FindFaces $model.entities

    # Color found faces green
    AnalyseModel.FoundFaces $faceArray

    # Remove dublicate vertices, as they a for each edge, if more edges use the
    # same vertex - there are dublicate vertices in the array.
    $vertexArray.uniq!

    puts "#{$faceArray.count} faces found!"
    puts "#{$edgeArray.count} edges found!"
    puts "#{$vertexArray.count} vertices found!"

    puts "Checking all vertices to be inside the lasercutting machine boundaries..." if $debugAnalyseModel

    AnalyseModel.CheckBoundaries $vertexArray

    # If there are vertices out of bound return with error

    $programState = 1

    t2 = Time.now

    puts "Model analysed! It took #{t2 - t1} seconds."

  end

  def self.AnalyseFaces

    unless $programState == 1

      # Give a waring to analyse model

      return

    end

    puts "Analysing faces v1.2"

    t1 = Time.now

    $faceArray.each do |face|

      # Check for top and bottom
      next if AnalyseFaces.TopBottom face

      # Check for faces with too many vertices (This is probably not necessary)
      next if AnalyseFaces.TooManyVertices face

      # Check if faces is too angled
      next if AnalyseFaces.TooAngled face

      # Rest of faces is cutting faces
      AnalyseFaces.CutThisFace face, $cuttingArray # Function to color remaining red and put them into cutting faces array

    end

    puts "#{$cuttingArray.count} faces to cut!"

    $programState = 2

    t2 = Time.now

    puts "Faces Analysed! It took #{t2 - t1} seconds."

  end

  def self.CalculateCuttingStrategy

    unless $programState == 2

      # Give a waring to analyse faces

      return

    end

    puts "Calculating cutting faces v1.7"

    t1 = Time.now

    # Hide all edges, so raytest does not cause unessacary trouble

    puts "Hidding all edges..." if $debugCalculateCuttingStrategy

    $edgeArray.each do |edge|

      edge.hidden = true

    end

    # Clear the array
    $cuttingStrategy.clear

    CalculateCuttingStrategy.ClearCutRay

    # Loop through all 3 strategies
    $cuttingArray.each_with_index do |cuttingFace, cutting_index|

      puts "Face #{cutting_index}..." if $debugCalculateCuttingStrategy

      # Create new face cutting strategy
      faceCuttingStrategy = FaceCuttingStrategy.new(cuttingFace)

      # Push to the array
      $cuttingStrategy.push(faceCuttingStrategy)

      # Calculate top and bottom vertices
      CalculateCuttingStrategy.TopBottomVertices faceCuttingStrategy

      # Calculate OuterVertices
      CalculateCuttingStrategy.OuterVertices faceCuttingStrategy

      puts "First Strategy" if $debugStrategy1

      # --- First Strategy ---
      next if CalculateCuttingStrategy.FirstStrategy faceCuttingStrategy, cutting_index

      puts "Second Strategy" if $debugStrategy2

      # --- Second Raytest ---
      next if CalculateCuttingStrategy.SecondStrategy faceCuttingStrategy, cutting_index

      puts "Third Strategy"  if $debugStrategy3

      # --- Third Raytest: Viften / Kegle ---
      next if CalculateCuttingStrategy.ThirdStrategy faceCuttingStrategy, cutting_index

      # --- Face cannot be cut
      puts "Face #{cutting_index}. Face cannot be cut!" if $debugCalculateCuttingStrategy

      faceCuttingStrategy.cuttable = false
      faceCuttingStrategy.face.material = "black"
      faceCuttingStrategy.face.back_material = "black"

    end

    # Calculate Actual Laser Positions and Orientations

    $cuttingStrategy.each do |faceCuttingStrategy|

      CalculateCuttingStrategy.LaserCut faceCuttingStrategy
      CalculateCuttingStrategy.CalculateOrientation faceCuttingStrategy

    end

    if $drawLaserCut

      puts "Drawing #{$cuttingStrategy.size} lasercuts" if $debugCalculateCuttingStrategy

      counter = 0

      $cuttingStrategy.each do |faceCuttingStrategy|

        puts "#{faceCuttingStrategy.strategy}" if $debugCalculateCuttingStrategy

        # If the face cannot be cut, proceed.
        if faceCuttingStrategy.cuttable != true

          $entities.add_line(faceCuttingStrategy.rays[0])
          #$entities.add_line(faceCuttingStrategy.rays[1])

          puts "Wrong cutting strategy: #{faceCuttingStrategy.strategy}"  if $debugCalculateCuttingStrategy

          next

        end

        counter = counter + 1

        # Add line
        $laserCutArray.push($entities.add_line faceCuttingStrategy.laserStartPosition, faceCuttingStrategy.laserEndPosition)

      end

      puts "Drawed #{counter} laser cuts"

    end

    # Show all cutting rays

    if $drawRaytest
      $cuttingStrategy.each_with_index do |faceCuttingStrategy, strategy_index|

        # If the face cannot be cut, proceed.
        next if faceCuttingStrategy.cuttable != true

        puts "Drawing strategy #{strategy_index}, Strategy: #{faceCuttingStrategy.strategy}"

        # Add lines
        $laserRayArray.push($entities.add_line faceCuttingStrategy.rays[0])
        $laserRayArray.push($entities.add_line faceCuttingStrategy.rays[1])

        #puts "Ray[0]: #{faceCuttingStrategy.rays[0].to_s}, Ray[1]: #{faceCuttingStrategy.rays[1].to_s}" if $debugLaserCut

      end
    end

    # Show all edges again...
    $edgeArray.each do |edge|

      edge.hidden = false

    end

    $programState = 3

    t2 = Time.now

    puts "Cutting strategy calculated! It took #{t2 - t1} seconds."

  end

  def self.CalculateTrajectory

    unless $programState == 3

      # Give a waring to calculate cutting strategies

      return

    end

    puts "Calculating Trajectory v2.2"

    t1 = Time.now

    # Clear the array
    $gcodeArray.clear

    # Clear the cut and ray array and erase lines
    CalculateCuttingStrategy.ClearCutRay

    # New temporay array for the unpathed gcodes
    tempGCodeArray = Array.new

    # Load all the [G1] cuts from the strategy array
    CalculateTrajectory.GetCuts tempGCodeArray

    # Calculate shortest path between vectors
    CalculateTrajectory.PathAlgorithm tempGCodeArray

    $gcodeArray.each do |gcode|

      # Calculate relative path from absolute points and orienations
      unless CalculateTrajectory.RelativeGCodeRelativeXYZ gcode

        # Need to create some function to delete this element if it's 0,0,0,0,0

        next

      end

      CalculateTrajectory.WriteGCodeString gcode

    end

    # Draw all the GCodes
    CalculateTrajectory.DrawGCodes

    $programState = 4

    t2 = Time.now

    puts "Trajectory Calculated! It took #{t2 - t1} seconds."

  end

  def self.ExportGCode

    unless $programState == 4

      # Give a waring to calculate trajectory

      return

    end

    puts "Export GCode v1.0"

    t1 = Time.now

    filepath_filename = nil

    filepath_filename = UI.savepanel("Save GCode File", "", "gcodes.gcode")

    puts "#{filepath_filename}" if $debugExportGCode

    puts "#{$gcodeArray.size} lines of instructions." if $debugExportGCode

    if filepath_filename == nil

      t2 = Time.now

      puts "Failed to create file. It took #{t2 - t1} seconds."

      return

    end

    # Write all the gcodes to the file
    File.open(filepath_filename, "w") do |line|

      # Start with the G91 to state it is relative codes
      line.puts("G91")

      # Loop through all GCodes and check if they got a string
      $gcodeArray.each_with_index do |gcode, index|

        # Write the gcode string to the file
        line.puts "#{gcode.string}" if gcode.string != nil

        puts "Writing [#{index}]: #{gcode.string}" if $debugExportGCode

      end

    end

    t2 = Time.now

    puts "Created a file with all the gcodes! It took #{t2 - t1} seconds."

  end

  # ---

  # Developer Utilities

  # ---

  def self.GenerateTestModels

    puts "Generate Test Models. v0.2"

    model = Sketchup.active_model

    testModelPath = File.join(File.dirname(__FILE__),'/compute5axisgcode/testmodels//test-geometrier-laser.skp')

    model.import(testModelPath)

  end

  def self.GenerateSimpleTestModel

    puts "Generate Simple Test Model. v0.1"

    model = Sketchup.active_model

    testModelPath = File.join(File.dirname(__FILE__),'/compute5axisgcode/testmodels/test-simplemodel.skp')

    model.import(testModelPath)

  end

  def self.UpdateExtension

    puts "Updating modules. v2.1"

    projectdir = File.dirname(__FILE__)

    load projectdir + "/compute5axisgcode/settings.rb"
    load projectdir + "/compute5axisgcode/analysemodel.rb"
    load projectdir + "/compute5axisgcode/analysefaces.rb"
    load projectdir + "/compute5axisgcode/calculatecuttingstrategy.rb"
    load projectdir + "/compute5axisgcode/pathalgorithm.rb"
    load projectdir + "/compute5axisgcode/exportgcode.rb"
    #load projectdir + "/analysecuttingfaces.rb"


    # puts projectdir

  end

  # ---

  # User Interface Dropdown Menu

  # ---

  unless file_loaded?(__FILE__)

    menu = UI.menu('Plugins')

    menu.add_item('1. Analyse Model') {self.AnalyseModel}
    menu.add_item('2. Analyse Faces') {self.AnalyseFaces}
    #menu.add_item('Analyse Cutting Faces') {self.AnalyseCuttingFaces}
    menu.add_item('3. Calculate Cutting Strategy') {self.CalculateCuttingStrategy}
    menu.add_item('4. Calculate Trajectory') {self.CalculateTrajectory}
    #menu.add_item('Generate GCode') {self.GenerateGCode}
    menu.add_item('5. Export GCode') {self.ExportGCode}
    #menu.add_item('Find points in faces') {self.PathAlgorithm}

    # Sub Menu with Developing Tools

    # Remove everything and generate test models (Used for development purposes)
    menu.add_item('Generate Test Models') {self.GenerateTestModels}
    #menu.add_item('Generate Simple Test Model') {self.GenerateSimpleTestModel}

    # To remove extension (Used for development purposes)
    menu.add_item('Developer: Update Extension') {self.UpdateExtension}

    file_loaded(__FILE__)

  end

end
