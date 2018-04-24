# Inspiration from Kimpastro: https://forums.sketchup.com/t/count-the-total-number-of-faces-in-a-model-of-a-really-complex-model/15755/2

# By Jesper Kirial and Niklas Buhl



faceCount = 0

faceArray = Array.new

=begin

  Recursive function to loop through an entity to find all faces, components and groups
  If it finds a Group or ComponentInstance it call itself.

=end

def FaceCheck entity, count, array

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

def TooManyVertices face

  vertexCount = face.vertices.length

  if vertexCount > 4

    face.material = "yellow"
    face.back_material = "yellow"

    return true

  end

  return false

end

def TopBottom face

  angle = face.normal.angle_between Geom::Vector3d.new(0,0,1)

  angle = angle * 180 / Math::PI

  angle = angle.round

  #puts "Angle: #{angle}"

  if angle == 0 || angle == 180

    face.material = "blue"
    face.back_material = "blue"

  end

end

def AnalyseFaces array

  array.each do |face|

    # Check for top and bottom
    next if TopBottom face

    # Check for faces with too many vertices
    next if TooManyVertices face

  end

end

def GreenFace array

  array.each do |face|

    face.material = "green"
    face.back_material = "green"

  end

end


# Analyse current model for faces
FaceCheck Sketchup.active_model.entities, faceCount, faceArray

# Color all found faces green
GreenFace faceArray

# Analyse found faces
AnalyseFaces faceArray

#puts "Loop Complete! Face Count: #{faceCount}"
#puts "#{faceArray}"
