require 'sketchup.rb'

# Project by Jesper Kirial and Niklas Buhl

# Analyse Model
require_relative 'analysemodel.rb'

# Cutting Strategy
require_relative 'cuttingstrategy.rb'

# Trajectory Planning
require_relative 'trajectoryplanning.rb'

# Export GCode
require_relative 'exportgcode.rb'

# Test systems
require_relative 'first.rb'

module Main

  puts "Loading all systems..."

  include First
  include AnalyseModel
  include CuttingStrategy
  include TrajectoryPlanning
  include ExportGCode
  include First

  puts "All systems go! All updated."

  def self.hello_world

    puts "Hello, World!"

  end

  # def self.hello_first
  #
  #   First.first_method
  #
  # end

  def self.example_model

    # Create a really nice example model!

    puts "Creating random examples model..."

  end

  def self.analyse_model

    AnalyseModel.find_vertices

    AnalyseModel.find_planes

    AnalyseModel.analyse_planes

  end

  def self.cutting_strategy

    CuttingStrategy.select_strategy

    CuttingStrategy.cutting_path_strategy_a

    CuttingStrategy.cutting_path_strategy_b

    CuttingStrategy.cutting_path_strategy_c

  end

  def self.trajectory_planning

    TrajectoryPlanning.generate_travel_points

    TrajectoryPlanning.optimize_trajectory

    TrajectoryPlanning.complete_trajectory

  end

  def self.export_gcode

    ExportGCode.generate_gcode

    ExportGCode.create_new_file

    ExportGCode.write_gcode_to_file

  end

  unless file_loaded?(__FILE__)

    menu = UI.menu('Plugins')

    menu.add_item('Hello World') {self.hello_world}
    # Learning about functions in other files
    # menu.add_item('Hello First World') {self.hello_first}
    menu.add_item('Example Model') {self.example_model}
    menu.add_item('Analyse Model') {self.analyse}
    menu.add_item('Generate Cutting Paths') {self.cutting_strategy}
    menu.add_item('Trajectory Planning') {self.trajectory_planning}
    menu.add_item('Export GCode') {self.export_gcode}

    menu.add_item('Remove Extension') {self.analyse_model}

    file_loaded(__FILE__)

  end

end
