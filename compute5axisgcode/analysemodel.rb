# By Jesper Kirial and Niklas Buhl

module AnalyseModel

  def self.ExplodeModel entities

    # Recursive function to explode all components and groups with each other

    entities.each do |entity|

      if entity.is_a?(Sketchup::ComponentInstance) || entity.is_a?(Sketchup::Group)

        ExplodeModel entity.definition.entities

        # Exlode entity
        entity.explode

      end

    end

  end

  def self.FindFaces entities

    # Inspiration from Kimpastro: https://forums.sketchup.com/t/count-the-total-number-of-faces-in-a-model-of-a-really-complex-model/15755/2

    # Loop through all the entities

    entities.each do |entity|

      # Check if it is a Face
      if entity.is_a?(Sketchup::Face)

        # Add the Face to the array
        $faceArray.push(entity)

      end

      if entity.is_a? (Sketchup::Edge)

        # Add the edge to the array
        $edgeArray.push(entity)

        # Add vertices to the array
        $vertexArray.push(entity.start)
        $vertexArray.push(entity.end)


      end

      # Chech if it is a ComponentInstance
      if entity.is_a?(Sketchup::ComponentInstance)

        puts "Found a ComponentInstance" if $debugAnalyseModel

        # Recursive in the entity
        FindFaces entity.definition.entities

      end

      # Check if it is a Group
      if entity.is_a?(Sketchup::Group)

        puts "Found a Group"  if $debugAnalyseModel

        # Recursive in the entity
        FindFaces entity.definition.entities

      end

    end

  end

  def self.CheckBoundaries vertexArray

    # Check the boundary for each vertex

    vertexArray.each do |vertex|

      # Get values
      x = vertex.position.x
      y = vertex.position.y
      z = vertex.position.z

      puts "Vertex: #{x}, #{y}, #{z}" if $debugAnalyseModel

      # Check if all of the xyz-values are inside the boundaries
      next if x >= 0 && x <= $tableWidth && y >= 0 && y <= $tableDepth && z >= 0 && z <= $tableHeight

      puts "Vertex: #{vertex.position.to_s} is out of boundaries!" if $debugAnalyseModel

      # If a vertex is outside, get all the connected faces
      faces = vertex.faces

      faces.each do |face|

        # Paint them black
        face.material = "black"
        face.back_material = "black"

      end

    end

  end

  def self.FoundFaces array

    # Color all faces found green

    array.each do |face|

      face.material = "green"
      face.back_material = "green"

    end

  end

end
