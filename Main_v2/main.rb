# Project by Jesper Kirial and Niklas Buhl

require 'sketchup.rb'

module Main

  # ---

  # Primary Methods

  # ---

  def AnalyseModel

    puts "Analysing model..."

    puts "Model Analysed!"

  end

  def AnalyseCuttingFaces

    puts "Analysing cutting faces..."

    # Analyse each face

    

    puts "Cutting faces analysed!"

  end

  def CalculateCuttingStrategy

    puts "Calculating cutting strategy..."

    # Optimize each cutting faces

    # Optimize cutting and moving path

    puts "Cutting strategy calculated!"

  end

  def GenerateGCode

    puts "Generating GCode..."

  end

  def ExportGCode

    puts "Export GCode..."

  end

  # ---

  # Developer Utilities

  # ---

  def GenerateTestModels

  end

  def UpdateExtension

  end

  # ---

  # User Interface Toolbar

  # ---

  # Create new toolbar with buttons.
  toolbar = UI::Toolbar.new "5 Axis Lasercutter"

  cmd = UI::Command.new("Analyse Model") { AnalyseModel }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Analyse Cutting Faces") { AnalyseCuttingFaces }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Calculate Cutting Strategy") { CalculateCuttingStrategy }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Generate GCode") { GenerateGCode }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Export GCode") { ExportGCode }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Generate Test Models") { GenerateTestModels }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Update Extension") { UpdateExtension }
  toolbar.add_item cmd

  toolbar.show

  toolbar.each { | item |
    puts item
  }

end
