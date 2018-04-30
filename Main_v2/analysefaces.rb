require 'sketchup.rb'

module AnalyseFaces

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

  def TooManyVertices face

    vertexCount = face.vertices.length

    if vertexCount > 4

      face.material = "yellow"
      face.back_material = "yellow"

      return true

    end

    return false

  end

end
