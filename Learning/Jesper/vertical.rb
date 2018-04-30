

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