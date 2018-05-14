require 'sketchup.rb'

module AnalyseFaces

  # Check if the faces is top or bottom

  def self.TopBottom face

    angle = face.normal.angle_between Geom::Vector3d.new(0,0,1)

    angle = angle * 180 / Math::PI

    angle = angle.round

    #puts "Angle: #{angle}"

    if angle == 0 || angle == 180

      face.material = "blue"
      face.back_material = "blue"

      return true

    end

    return false

  end

  # Check if the face has too many vertices

  def self.TooManyVertices face

    vertexCount = face.vertices.length

    if vertexCount > 4

      face.material = "yellow"
      face.back_material = "yellow"

      return true

    end

    return false

  end


# Make sure the angles of the faces do not exceed 45 degreess

    def self.TooAngled face

          if face.normal.z < - 0.70710678118654 && face.normal.z > 0.70710678118654

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
