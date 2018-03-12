require 'sketchup.rb'
require_relative 'first.rb'

module Main

  include First

  def self.hello_world

    puts "Hello World! 8"

  end

  def self.hello_first

      first_method

  end

  def self.analyse_model

    puts "Analyzing "

  end

  def self.export_gcode

    puts "Exporting GCode..."

  end

  unless file_loaded?(__FILE__)

    menu = UI.menu('Plugins')

    menu.add_item('Hello World') {
      self.hello_world
    }

    menu.add_item('Hello First World') {

      self.hello_first

    }

    menu.add_item('Analyse Model') {
      self.analyse_model
    }

    menu.add_item('Export GCode') {
      self.export_gcode
    }

    file_loaded(__FILE__)
  end
end
