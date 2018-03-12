model = Sketchup.active_model

entities = model.active_entities

points = []

points[0] = Geom::Point3d.new(0, 0, 0)

points[1] = Geom::Point3d.new(1.m, 0, 0)

points[2] = Geom::Point3d.new(1.m, 1.m, 0)

points[3] = Geom::Point3d.new(0, 1.m, 0)

face = entities.add_face(points)

connected = face.all_connected
