model = Sketchup.active_model
model.start_operation('Create Donut', true)
group = model.active_entities.add_group
# Create a filled circle which later will be extruded along a path to
# create a donut shape.
num_segments = 24
center_radius = 1.m
thickness = 0.5.m
origin = Geom::Point3d.new(0, center_radius, 0)
circle = group.entities.add_circle(origin, X_AXIS, thickness, num_segments)
face = group.entities.add_face(circle)
# Create a temporary path for follow me to use to perform the revolve.
# This path should not touch the face.
path = group.entities.add_circle(ORIGIN, Z_AXIS, center_radius, num_segments)
# This creates the donut.
face.followme(path)
# The temporary path is no longer needed.
# group.entities.erase_entities(path)
model.commit_operation
