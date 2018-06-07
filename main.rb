# Project by Jesper Kirial and Niklas Buhl

# Too add to Sketchup on Niklas

=begin

UI.menu.add_item("G-Code") { load("/Users/nbxyz/Develop/Sketchup-Gcode-5-Axis-Laser-Cutter/main.rb");}

=end

# Too add to Sketchup on Jesper

  #     UI.menu.add_item("G-Code") { load("C:\\Projects\\Sketchup-Gcode-5-Axis-Laser-Cutter\\main.rb");}

# Z is the up axis

require 'sketchup'
# require 'os' # https://rubygems.org/gems/os // How to add it into the Skethcup path

require_relative 'analysemodel'
require_relative 'analysefaces'
#require_relative 'analysecuttingfaces'
#require_relative 'calculatecuttingstrategy'
require_relative 'calculatecuttingstrategyv2'
require_relative 'settings'
require_relative 'pathalgorithm'

module Main

  # Hello World

  puts "Hello World. v0.3 - UpdateExtension working on mac"

  # Includes

  include AnalyseModel
  include AnalyseFaces

  include CalculateCuttingStrategy
  include PathAlgorithm

  #include CalculateCuttingStrategy
  #include AnalyseCuttingFaces

  # Model and Layers

  $model
  #$modelClone
  $entities
  $layers

  $originallayer
  $cuttingtestlayer
  $gcodelayer



  # Face Arrays

  $edgeArray = Array.new # Collect all edges
  $faceArray = Array.new # Keep track of found faces
  $cuttingArray = Array.new # Keep track of the faces to be cut
  $cuttingStrategy = Array.new # Keep track of cutting strategies

  $analysedArray = Array.new # Keep the CuttingFace class in array
  $cuttingStrategiesArray = Array.new # Keep track for the cutting strategies

  # Primary Methods

  # ---

  def self.main_method

    puts "Hello Main Method"

  end

  def self.AnalyseModel

    t1 = Time.now

    puts "Analysing model to find faces..."

    # Updating all sketchup entities
    $model = Sketchup.active_model
    $entities = $model.active_entities
    $layers = $model.layers

    # Layers
    #$originallayer = $layers.layer
    #$originallayer.name ="OriginalLayers"
    $cuttingtestlayer = $layers.add("CuttingTestLayer")
    $gcodelayer = $layers.add("GCodeLayer")

    # Clear faceArray and cuttingArray
    $faceArray.clear
    $edgeArray.clear
    $cuttingArray.clear

    # Analyse model for faces
    AnalyseModel.FindFaces $model.entities

    # Color found faces green
    AnalyseModel.FoundFaces $faceArray

    puts "#{$faceArray.count} faces found!"
    puts "#{$edgeArray.count} edges found!"

    t2 = Time.now

    puts "Model analysed! It took #{t2 - t1} seconds."

  end

  def self.AnalyseFaces

    puts "Analysing faces..."

    t1 = Time.now

    $faceArray.each do |face|

      # Check for top and bottom
      next if AnalyseFaces.TopBottom face

      # Check for faces with too many vertices
      #next if AnalyseFaces.TooManyVertices face

      # Check if faces is too angled
      next if AnalyseFaces.TooAngled face

      # Rest of faces is cutting faces
      AnalyseFaces.CutThisFace face, $cuttingArray # Function to color remaining red and put them into cutting faces array

    end

    puts "Analysed found faces!"

    puts "#{$cuttingArray.count} faces to cut!"

    t2 = Time.now

    puts "Faces Analysed! It took #{t2 - t1} seconds."

  end

  def self.CalculateCuttingStrategy

    puts "Calculating cutting faces (Version 0.2)..."

    t1 = Time.now

    # Hide all edges...

    puts "Hidding edges..." if $debugCalculateCuttingStrategy

    $edgeArray.each do |edge|

      edge.hidden = true

    end

    $cuttingStrategy = Array.new
    $cuttingStrategy.clear

    $cuttingArray.each do |cuttingFace|

      # -- Cutting Strategy 1

      # 0. Create new face cutting strategy
      faceCuttingStrategy = FaceCuttingStrategy.new(cuttingFace)
      $cuttingStrategy.push(faceCuttingStrategy)

      # Calculate top and bottom vertices
      CalculateCuttingStrategy.TopBottomVertices faceCuttingStrategy

      # Calculate OuterVertices
      CalculateCuttingStrategy.OuterVertices faceCuttingStrategy

      # Calculate cutting dirction vector
      vector = CalculateCuttingStrategy.UpVector(faceCuttingStrategy)


      # --- First Raytest ---
      faceCuttingStrategy.rays[0] = CalculateCuttingStrategy.GenerateCuttingLine faceCuttingStrategy.outerVertices[0].position, vector
      faceCuttingStrategy.rays[1] = CalculateCuttingStrategy.GenerateCuttingLine faceCuttingStrategy.outerVertices[1].position, vector

      rayA = CalculateCuttingStrategy.RayTest faceCuttingStrategy.rays[0], faceCuttingStrategy.face
      rayB = CalculateCuttingStrategy.RayTest faceCuttingStrategy.rays[1], faceCuttingStrategy.face

      if !rayA && !rayB

        faceCuttingStrategy.cuttable = true

        puts "Strategy A is successful!" if $debugRaytest

      else
        puts "Strategy is not successful, proceding..." if $debugRaytest

      end

      next if !rayA && !rayB


      # --- Second Raytest ---

      # 4. For each outer vertex

      #puts "This vertex: #{faceCuttingStrategy.outerVertices[0]}"

      faceCuttingStrategy.outerVertices.each_with_index do |outerVertex, index|

        # 4.1 Find cuttable edge from outerVertex

        edges = outerVertex.edges

        edges.each do |edge|

          #puts "This is: #{edge}"

          # 4.4.1 Check if the edge is on the face
          next unless edge.used_by?(cuttingFace)

          # 4.4.2 Check if the edge is less that 45 degress

          angle = edge.line[1].angle_between(Geom::Vector3d.new(0,0,0))

          #puts "Edge Angle: #{angle}"
          next if angle > Math::PI / 2

          # 4.4.3 Check if the edge is more that 135 degress
          next if angle < 3 * Math::PI / 4

          # 4.4.3 Generate cutting line from edge(vector) and outer vertex Lines[index]

          # 4.4.4 Raytest: Lines[index]: If true, continue
          cuttingFace.vertices.each do |faceVertex|

            # 4.4.4.1 Check if the vertex is used by the original edge
            next if faceVertex.used_by(edge)

            # 4.4.4.2 Generate cutting line from the vertex and vector from the edge

            # 4.4.4.3 Raytest: Outer vertex cutting line and cutting line from the vertices

          end

        end

        # 4.4 For other vertices not connected to the edge

      end

      # --- Third Raytest: Viften

      # --- Face cannot be cut

      puts "Face cannot be cut!" if $debugCalculateCuttingStrategy

      faceCuttingStrategy.face.material = "black"
      faceCuttingStrategy.face.back_material = "black"

    end

    # Show all cutting rays

    if $drawRaytest
      $cuttingStrategy.each do |faceCuttingStrategy|

        $entities.add_line faceCuttingStrategy.rays[0]
        $entities.add_line faceCuttingStrategy.rays[1]

      end
    end

    # Show all edges again...
    $edgeArray.each do |edge|

      edge.hidden = false

    end

    t2 = Time.now

    puts "Cutting strategy calculated! It took #{t2 - t1} seconds."

  end

=begin

  def self.AnalyseCuttingFaces

    puts "Analysing cutting faces..."

    t1 = Time.now

    $analysedArray = Array.new

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
      #AnalyseCuttingFaces.AvailableCuttingEdges thisCuttingFace

      # Find a vector parallel to the plane in rectangular to the normal vector upwards
      #AnalyseCuttingFaces.PlaneVector thisCuttingFace

      $analysedArray.push(thisCuttingFace)

    end

    t2 = Time.now

    puts "#{$analysedArray.count} cutting faces analysed! It took #{t2 - t1} seconds."

  end

=end

  def self.PathAlgorithm

    $faceArray.each do |face|

      PathAlgorithm.Findpoints face
    # make an array with the points of the found faces

    end

  end

=begin

  def self.CalculateCuttingStrategy

    puts "Calculating cutting strategy for each cutting face..."

    t1 = Time.now

    $cuttingStrategiesArray.clear

    $cuttingArray.each do |cuttingFace|

      tempFaceCuttingStrategy = FaceCuttingStrategy.new

      # Test cutting strategy 1

      # Test cutting strategy 2A

      # Test cutting strategy 2B

      # Test cutting strategy 3

    end

    t2 = Time.now

    puts "Cutting strategy calculated! It took #{t2 - t1} seconds."

  end

=end

  def self.CalculateTrajectory

    puts "Calculating Trajectory..."

    # Calculate shortest path between vectors

    puts "Trajectory Calculated!"

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

    puts "Updating modules. v1.1"

    projectdir = File.dirname(__FILE__)

    load projectdir + "/settings.rb"
    load projectdir + "/analysemodel.rb"
    load projectdir + "/analysefaces.rb"
    #load projectdir + "/analysecuttingfaces.rb"
    load projectdir + "/calculatecuttingstrategyv2.rb"

    # puts projectdir

  end

  # ---

  # User Interface Dropdown Menu

  # ---

  unless file_loaded?(__FILE__)

    menu = UI.menu('Plugins')

    menu.add_item('Analyse Model') {self.AnalyseModel}
    menu.add_item('Analyse Faces') {self.AnalyseFaces}
    #menu.add_item('Analyse Cutting Faces') {self.AnalyseCuttingFaces}
    menu.add_item('Calculate Cutting Strategy') {self.CalculateCuttingStrategy}
    menu.add_item('Calculate Cutting Trajectory') {self.CalculateCuttingTrajectory}
    #menu.add_item('Generate GCode') {self.GenerateGCode}
    menu.add_item('Export GCode') {self.ExportGCode}
    menu.add_item('Find points in faces') {self.PathAlgorithm}

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
