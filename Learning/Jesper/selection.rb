# Copyright 2012, Trimble Navigation Limited

# This software is provided as an example of using the Ruby interface
# to SketchUp.

# Permission to use, copy, modify, and distribute this software for 
# any purpose and without fee is hereby granted, provided that the above
# copyright notice appear in all copies.

# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#-----------------------------------------------------------------------------

module Sketchup::Examples

# Two functions that were requested on the forum

# Invert the current selection
def self.invert_selection
    model = Sketchup.active_model
    ss = model.selection
    model.entities.each {|e| ss.toggle(e)}
end

# Hide everything that is not selected
def self.hide_rest
    model = Sketchup.active_model
    ss = model.selection
    model.start_operation $exStrings.GetString("Hide Rest")
    model.entities.each {|e| e.visible = false if not ss.contains?(e) }
    model.commit_operation
end

#-------------------------------------------------------------------------
# This function allows you to select things in the model based on a predicate
# that you pass it as a block.  It can allow for some very flexible kinds 
# of selections.

# This expression will select everything that is on the Layer named "Joe"
# do_select {|e| e.layer.name == "Joe"}

# This one will select everything that is on either layer "Joe" or layer "Bob"
# do_select {|e| e.layer.name == "Joe" || e.layer.name == "Bob"}

# You can also use regular expressions.  The following command would
# select everything on layers whose name started with "W".  for example
# everything on layers "Walls" and "Windows"
# do_select {|e| (e.layer.name =~ /W.*/) == 0}

# This will select all Edges in the model
# do_select {|e| e.kind_of?(Sketchup::Edge)}

# This will select all edges that are on layer "Joe"
# do_select {|e| e.kind_of(Sketchup::Edge) && e.layer.name == "Joe"}

def self.do_select

    model = Sketchup.active_model

    # First clear the selection
    ss = model.selection
    ss.clear
    
    # iterate through everything in the model
    for ent in model.entities
        if( yield(ent) )
            ss.add(ent)
        end
    end
    
    # return the number of things selected
    ss.length
end

# These examples add a couple of menu items to select things in the model 
# based on Layer or Material.  The also demonstrate putting a popup list
# in an input box

def self.select_by_layer
    # First get a list of all of the layers in the model
    model = Sketchup.active_model
    layers = model.layers
    names = layers.collect {|l| l.name}
    
    # Display a dialog to pick the layer to select
    prompts = [$exStrings.GetString("Layer")]
    values = [names[0]]
    enums = [names.join("|")]
    results = inputbox prompts, values, enums, $exStrings.GetString("Select By Layer")
    return if not results
    
    # Now select everything on the selected layer
    layername = results[0]
    do_select {|e| e.layer.name == layername}
end

def self.select_by_material
    # First get a list of all of the materials in the model
    model = Sketchup.active_model
    materials = model.materials
    names = materials.collect {|m| m.name}
    displaynames = materials.collect {|m| m.display_name}
    
    # Display a dialog to pick the material to select
    prompts = [$exStrings.GetString("Material")]
    values = [displaynames[0]]
    enums = [displaynames.join("|")]
    results = inputbox prompts, values, enums, $exStrings.GetString("Select By Material")
    return if not results
    
    # Now select everything with the selected Material
    index = displaynames.index(results[0])
    materialname = index ? names[index] : $exStrings.GetString("Default")
    do_select {|e| e.material && (e.material.name == materialname)}
end

end # module Sketchup::Examples
