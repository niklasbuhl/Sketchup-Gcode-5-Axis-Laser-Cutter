# Inspiration from Kimpastro: https://forums.sketchup.com/t/count-the-total-number-of-faces-in-a-model-of-a-really-complex-model/15755/2

# By Jesper Kirial and Niklas Buhl

=begin

  Recursive function to loop through an entity to find all faces, components and groups
  If it finds a Group or ComponentInstance it call itself.

=end

module AnalyseModel

  def self.FindFaces entity, count, array

    # Loop through all the entities.

    entity.each do |e|

      if e.is_a?(Sketchup::Face) # Check if it is a Face.

        count += 1 # Increment by 1

        array.push(e) # Add the Face to the array

        puts "Entity is a Face! Current count is: #{count}"

      end

      if e.is_a?(Sketchup::ComponentInstance) # Chech if it is a ComponentInstance

        # puts "Found a ComponentInstance"

        FindFaces e.definition.entities, count, array # Recursive in the entity

      end

      if e.is_a?(Sketchup::Group) # Check if it is a Group

        # puts "Found a Group"

        FindFaces e.definition.entities, count, array # Recursive in the entity

      end

    end

  end

  def self.FoundFaces array

    array.each do |face|

      face.material = "green"
      face.back_material = "green"

    end

  end

end
