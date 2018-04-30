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

    end

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

<<<<<<< HEAD
          if face.normal.z > - 0.70710678118654 && face.normal.z < 0.70710678118654
=======
          if face.normal.z>-0.70710678118654 && face.normal.z<0.70710678118654
>>>>>>> e9e1d2e36ce351e356a17238b24a4bad07297bf6

            face =  face.material = "cyan"
            face = face.back_material ="cyan"

            return true
          end

          return false
    end

  end
