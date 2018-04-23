# Inspiration from Kimpastro: https://forums.sketchup.com/t/count-the-total-number-of-faces-in-a-model-of-a-really-complex-model/15755/2

# By Jesper Kirial and Niklas Buhl

faceCount = 0

faceArray = Array.new

=begin

  Recursive function to loop through an entity to find all faces, components and groups
  If it finds a Group or ComponentInstance it call itself.

=end

def FaceCheck entity, count, array

  puts "Looping through entity v1.3"

  # Loop through all the entities.

  entity.each do |e|

    if e.is_a?(Sketchup::Face) # Check if it is a Face.

      count += 1 # Increment by 1

      array.push(e) # Add the Face to the array

      puts "Entity is a Face! Current count is: #{count}"

    end

    if e.is_a?(Sketchup::ComponentInstance) # Chech if it is a ComponentInstance

      # puts "Found a ComponentInstance"

      FaceCheck e.definition.entities, count, array # Recursive in the entity

    end

    if e.is_a?(Sketchup::Group) # Check if it is a Group

      # puts "Found a Group"

      FaceCheck e.definition.entities, count, array # Recursive in the entity

    end

  end

end

FaceCheck Sketchup.active_model.entities, faceCount, faceArray

#puts "Loop Complete! Face Count: #{faceCount}"
#puts "#{faceArray}"

def orderedFaceVertices face

  faceVertices = face.vertices

  faceVertices.each do |vertex|

    vertexPosition = vertex.position

    puts vertexPosition.inspect

  end

end

faceArray.each do |face|

  # puts face

  face.material = "red"
  face.back_material = "red"

  faceVertices face

end
