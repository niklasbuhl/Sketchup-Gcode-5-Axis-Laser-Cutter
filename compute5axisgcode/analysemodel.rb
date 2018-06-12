# Inspiration from Kimpastro: https://forums.sketchup.com/t/count-the-total-number-of-faces-in-a-model-of-a-really-complex-model/15755/2

# By Jesper Kirial and Niklas Buhl

=begin

  Recursive function to loop through an entity to find all faces, components and groups
  If it finds a Group or ComponentInstance it call itself.

=end

module AnalyseModel

  def self.Explode entities

    entities.each do |entity|

      if entity.is_a?(Sketchup::ComponentInstance) || entity.is_a?(Sketchup::Group)

        Explode entity.definition.entities

        entity.explode

      end

    end

  end

  def self.FindFaces entities

    # Loop through all the entities.

    entities.each do |entity|

      if entity.is_a?(Sketchup::Face) # Check if it is a Face.

        $faceArray.push(entity) # Add the Face to the array

      end

      if entity.is_a? (Sketchup::Edge)

        $edgeArray.push(entity)

        # Add vertices to the array
        $vertexArray.push(entity.start)
        $vertexArray.push(entity.end)


      end

      if entity.is_a?(Sketchup::ComponentInstance) # Chech if it is a ComponentInstance

        puts "Found a ComponentInstance" if $debugAnalyseModel

        FindFaces entity.definition.entities # Recursive in the entity

      end

      if entity.is_a?(Sketchup::Group) # Check if it is a Group

        puts "Found a Group"  if $debugAnalyseModel

        FindFaces entity.definition.entities # Recursive in the entity

      end

    end

  end

  def self.CheckBoundaries vertexArray

    # Check the boundary for each vertex

    vertexArray.each do |vertex|

      x = vertex.position.x
      y = vertex.position.y
      z = vertex.position.z

      puts "Vertex: #{x}, #{y}, #{z}" if $debugAnalyseModel

      next if x >= 0 && x <= $tableWidth && y >= 0 && y <= $tableDepth && z >= 0 && z <= $tableHeight

      puts "Vertex: #{vertex.position.to_s} is out of boundaries!" if $debugAnalyseModel

      faces = vertex.faces

      faces.each do |face|

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
