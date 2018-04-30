
require '/SketchUp/sketchup.rb'

module


def frominput

# Grab a handle to the currently active model (aka the one the user is
# looking at in SketchUp.)
model = Sketchup.active_model

# Grab other handles to commonly used collections inside the model.
entities = model.entities
layers = model.layers
materials = model.materials
component_definitions = model.definitions
selection = model.selection
    points = model.

# Now that we have our handles, we can start pulling objects and making
# method calls that are useful.
first_entity = entities[0]
UI.messagebox("First thing in your model is a #{first_entity.typename}")

number_materials = materials.length
UI.messagebox("Your model has #{number_materials} materials.")

new_edge = entities.add_line([0,0,0], [500,500,0])

end
