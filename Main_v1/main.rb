require 'sketchup.rb'

# Project by Jesper Kirial and Niklas Buhl

# Analyse Model
require_relative 'analyse_model.rb'

# Cutting Strategy
require_relative 'cutting_strategy.rb'

# Trajectory Planning
require_relative 'trajectory_planning.rb'

# Export GCode
require_relative 'export_gcode.rb'

module Main

  include Analyse_Model
  include Cutting_Strategy
  include Trajectory_Planning
  include Export_GCode

  def self.hello_world

    puts "Hello, World!"

  end

  def self.analyse_model

    find_vertices

    find_planes

    analyse_planes

  en

  def self.cutting_strategy

    select_strategy

    cutting_path_strategy_a

    cutting_path_strategy_b

    cutting_path_strategy_c

  end

  def self.trajectory_planning

    generate_travel_points

    optimize_trajectory

    complete_trajectory

  end

  def self.export_gcode

    generate_gcode

    create_new_file

    write_gcode_to_file

  end

  unless file_loaded?(__FILE__)

    menu = UI.menu('Plugins')

    menu.add_item('Hello World') {self.hello_world}
    menu.add_item('Analyse Model') {self.analyse_model}
    menu.add_item('Generate Cutting Paths') {self.cutting_strategy}
    menu.add_item('Trajectory Planning') {self.trajectory_planning}
    menu.add_item('Export GCode') {self.export_gcode}

    file_loaded(__FILE__)

  end

end
