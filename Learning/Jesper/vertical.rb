

# Default code, use or delete...
mod = Sketchup.active_model # Open model
ent = mod.entities # All entities in model
sel = mod.selection # Current selection




sel.clear;
        
    ent.grep(Sketchup::Face).each{|f|sel.add(f)if f.normal.z>-0.71 && f.normal.z<0.71}



def Angle face

    if face.normal > -Math::PI/4 && face.normal.z < Math::PI/4

        face.material = "cyan"
        face.back_material ="cyan"

    end

end



# By Jesper Kirial and Niklas Buhl


require 'sketchup.rb'

mod = Sketchup.active_model # Open model
ent = mod.entities # All entities in model
sel = mod.selection # Current selection
colored = array.new

module Main


mod.active_entities.grep(Sketchup::Face).each{ |f|
    
    colored.add(f)if f.normal.z>-0,70710678118654 && f.normal.z<0.70710678118654}

    
def color (colored)
     colored.each do |face|
      face =  face.material = "cyan"
      face = face.back_material ="cyan"
end
end

























angle = face.normal.angle_between Geom::Vector3d.new(0,0,1)

      angle = angle * 180 / Math::PI/4
  
      angle = angle.round


          if face.normal.z <= - Math::PI/4 && face.normal.z >= Math::PI/4

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