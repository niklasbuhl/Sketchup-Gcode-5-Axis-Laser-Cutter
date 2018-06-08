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

    pointA = Geom::Point3d.new()
    pointB = Geom::Point3d.new()

    vector = Geom::Vector3d.new()

    # Loop through all 3 strategies
    $cuttingArray.each_with_index do |cuttingFace, cutting_index|

      puts "Face #{cutting_index}..." if $debugCalculateCuttingStrategy

      # Create new face cutting strategy
      faceCuttingStrategy = FaceCuttingStrategy.new(cuttingFace)
      $cuttingStrategy.push(faceCuttingStrategy)

      # Calculate top and bottom vertices
      CalculateCuttingStrategy.TopBottomVertices faceCuttingStrategy

      # Calculate OuterVertices
      CalculateCuttingStrategy.OuterVertices faceCuttingStrategy

      # Calculate cutting dirction vector
      vector = CalculateCuttingStrategy.UpVector(faceCuttingStrategy)

      # Get the position of the outer vertices
      pointA = faceCuttingStrategy.outerVertices[0].position
      pointB = faceCuttingStrategy.outerVertices[1].position

      # --- First Raytest ---
      faceCuttingStrategy.rays[0] = CalculateCuttingStrategy.GenerateCuttingLine pointA, vector
      faceCuttingStrategy.rays[1] = CalculateCuttingStrategy.GenerateCuttingLine pointB, vector

      rayA = CalculateCuttingStrategy.RayTest faceCuttingStrategy.rays[0], faceCuttingStrategy.face
      rayB = CalculateCuttingStrategy.RayTest faceCuttingStrategy.rays[1], faceCuttingStrategy.face


      # Successful strategy 1
      if !rayA & !rayB

        faceCuttingStrategy.cuttable = true
        faceCuttingStrategy.strategy = "1"
        puts "Face #{cutting_index}. Strategy 1 is successful!" if $debugCalculateCuttingStrategy
        next

      end

      puts "Face #{cutting_index}. Strategy 1 is not successful, proceding..." if $debugCalculateCuttingStrategy

      # --- Second Raytest ---

      # For each outer vertex
      faceCuttingStrategy.outerVertices.each_with_index do |outerVertex, vertex_index|

        # Find cuttable edge from outerVertex

        edges = outerVertex.edges

        puts "Listing edges: #{edges}" if $debugStrategy2

        # For each edge connected to the outerVertices
        edges.each do |edge|

          #puts "This is: #{edge}" if $debugStrategy2

          # Check if the edge is on the face
          next unless edge.used_by?(cuttingFace)

          # Calculate the angle of the edge
          angle = edge.line[1].angle_between(Geom::Vector3d.new(0,0,1))

          puts "Edge Angle: #{angle * (180 / Math::PI) }. Less than: #{ (Math::PI / 4) * (180 / Math::PI) } or higher then: #{ 3 * Math::PI / 4 * (180 / Math::PI) }" if $debugStrategy2

          # Check if the edge is more that 45 degress and less than 135
          next if angle > Math::PI / 4 && angle < 3 * Math::PI / 4

          # Check if the edge is less that 135 degress
          #next unless angle > 3 * Math::PI / 4 && angle > Math::PI / 4

          puts "Angle is alright" if $debugStrategy2

          # Get the vector from the edge
          vector = edge.line[1] # Vector from the edge

          puts "Vector of line: #{vector.to_s}" if $debugStrategy2

          break

        end

        # Get point and vector for cutting line
        pointA = outerVertex.position # position from outerVertex

        # Generate cutting line from edge(vector) and outer vertex

        faceCuttingStrategy.rays[vertex_index] = CalculateCuttingStrategy.GenerateCuttingLine pointA, vector

        # Raytest
        rayA = CalculateCuttingStrategy.RayTest faceCuttingStrategy.rays[vertex_index], faceCuttingStrategy.face
        $entities.add_line(faceCuttingStrategy.rays[vertex_index]) if $debugStrategy2

        # If this ray did not succeed
        if rayA

          puts "Face #{cutting_index}. Stragety 2.#{vertex_index}a was not successful, proceeding..."
          next

        end

        # Find the vertice furthest away
        faceCuttingStrategy.manipulatedVertices.each do |manipulatedVertex|

          manipulatedVertex.projectedValue = manipulatedVertex.origVertex.position.distance_to_line(pointA, vector)

        end

        # Sort manipulatedVertex array to the projectedValue(distance(), Take the distances and sort them, including the origin which is zero
        faceCuttingStrategy.manipulatedVertices.sort! { |x,y| x.projectedValue <=> y.projectedValue }

        if $debugStrategy2

          #faceCuttingStrategy.manipulatedVertices.each { |manipulatedVertex| puts "All: #{manipulatedVertex.projectedValue}"}
          #puts "Highest: #{faceCuttingStrategy.manipulatedVertices.last.projectedValue}"

        end

        pointB = faceCuttingStrategy.manipulatedVertices.last.origVertex.position

        # Generate cutting line from the vertex and vector from the first edge

        tempRayB = CalculateCuttingStrategy.GenerateCuttingLine pointB, vector

        #faceCuttingStrategy.rays[1-vertex_index] = CalculateCuttingStrategy.GenerateCuttingLine pointB, vector

        # Raytest: Outer vertex cutting line and cutting line from the vertices
        rayB = CalculateCuttingStrategy.RayTest tempRayB, faceCuttingStrategy.face
        $entities.add_line(faceCuttingStrategy.rays[1-vertex_index]) if $debugStrategy2

        # Second ray test successful, break the loop for each
        if !rayA && !rayB

          faceCuttingStrategy.cuttable = true
          faceCuttingStrategy.rays[1-vertex_index] = tempRayB
          faceCuttingStrategy.strategy = "2.#{vertex_index}"
          puts "Face #{cutting_index}. Strategy 2.#{vertex_index} was successful!" if $debugCalculateCuttingStrategy
          puts "Breaking loop." if $debugStrategy2
          break

        end

        puts "Face #{cutting_index}. Strategy 2.#{vertex_index}b was not successful, proceeding..." if $debugCalculateCuttingStrategy

      end

      # Second ray test successful
      if !rayA && !rayB
        puts "Next (debugStrategy2)" if $debugStrategy2
        next
      end

      # --- Third Raytest: Viften

      # As they are already saved from above they should just be checked.

      rayA = CalculateCuttingStrategy.RayTest faceCuttingStrategy.rays[0], faceCuttingStrategy.face
      rayB = CalculateCuttingStrategy.RayTest faceCuttingStrategy.rays[1], faceCuttingStrategy.face

      # If they did not hit anything, proceed to next cuttingFace
      if !rayA && !rayB

        faceCuttingStrategy.cuttable = true
        faceCuttingStrategy.strategy = "3"
        puts "Face #{cutting_index}. Strategy 3 was successful!" if $debugCalculateCuttingStrategy
        next

      end

      puts "Face #{cutting_index}. Strategy 3 was not successful, proceeding..." if $debugCalculateCuttingStrategy

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

      $cuttingStrategy.each do |faceCuttingStrategy|

        $entities.add_line faceCuttingStrategy.laserStartPosition, faceCuttingStrategy.laserEndPosition

      end

    end

    # Show all cutting rays

    if $drawRaytest
      $cuttingStrategy.each_with_index do |faceCuttingStrategy, strategy_index|

        next if faceCuttingStrategy.cuttable != true

        puts "Drawing strategy #{strategy_index}, Strategy: #{faceCuttingStrategy.strategy}"

        $entities.add_line faceCuttingStrategy.rays[0]
        $entities.add_line faceCuttingStrategy.rays[1]

        #puts "Ray[0]: #{faceCuttingStrategy.rays[0].to_s}, Ray[1]: #{faceCuttingStrategy.rays[1].to_s}" if $debugLaserCut

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
