

# Default code, use or delete...
mod = Sketchup.active_model # Open model
ent = mod.entities # All entities in model
sel = mod.selection # Current selection




sel.clear;
        
    mod.active_entities.grep(Sketchup::Face).each{|f|sel.add(f)if f.normal.z>-0.71 && f.normal.z<0.71}



def Angle face

    if face.normal > -Math::PI/4 && face.normal.z < Math::PI/4

        face.material = "cyan"
        face.back_material ="cyan"

    end

end


