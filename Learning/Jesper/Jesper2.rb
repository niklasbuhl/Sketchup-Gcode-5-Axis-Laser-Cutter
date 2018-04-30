require 'sketchup.rb'


# Default code, use or delete...
mod = Sketchup.active_model # Open model
ent = mod.entities # All entities in model
sel = mod.selection # Current selection

i = 0




pts2 = []
(0..20).each { |i|
  pts2[i] = 30+rand(30)
}

pts2 = []
(0..20).each { |i|
  pts2[i] = 60+rand(60)
}

corn = []
(0..20).each { |i|
  corn[i] = 5+rand(18)
}



# Create the box
main_face = ent.add_face [0,0,0], [pts[0],0,0], [pts[0],pts[2],0], [pts2[0],pts2[1],0], [pts2[3],pts2[2],0], [0,pts[1],0]
main_face.reverse!
main_face.pushpull pts[3]
# Draw a line across the upper-right corner
cut1 = ent.add_line [0, 0, 0], [0,corn[2],pts[3]]
# Remove the new face
cut1.faces[1].pushpull -pts[0]

#cut2 = ent.add_line [0,pts[2],0], [0,pts[1]-corn[5],pts[3]]
# Remove the new face
#cut2.faces[0].pushpull -pts[3]

