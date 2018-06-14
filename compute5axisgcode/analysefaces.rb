require 'sketchup.rb'

module AnalyseFaces

  def self.TopBottom face

    # Check if the face is top or bottom

    # Get the normal of the face, which must be perpendicular to the z-axis
    angle = face.normal.angle_between Geom::Vector3d.new(0,0,1)

    # From radians to degrees
    angle = angle * 180 / Math::PI

    # Round the angle to make space for some tolerance
    angle = angle.round

    puts "Angle: #{angle}" if $debugTopBottom

    if angle == 0 || angle == 180

      face.material = "blue"
      face.back_material = "blue"

      return true

    end

    return false

  end

  # Check if the face has too many vertices

  def self.TooManyVertices face

    # Get the amount of vertices in the face
    vertexCount = face.vertices.length

    if vertexCount > 4

      face.material = "yellow"
      face.back_material = "yellow"

      return true

    end

    return false

  end

  def self.TooAngled face

    # Make sure the angles of the faces do not exceed 45 degreess

      if face.normal.z < -Math::PI/4 || face.normal.z > Math::PI/4

        face.material = "cyan"
        face.back_material = "cyan"

        return true

      end

      return false

  end

  def self.CutThisFace face, array

    face.material = "red"
    face.back_material = "red"

    array.push(face)

  end

end
