# By Jesper Kirial and Niklas Buhl    

# ruten på et face er angivet som n1 -> n2

# Start i a1. Slutter i a2

# fra a2 skal der måles afstand til alle andre noder for at afgøre hvor næste skæring ligger.

# hver gang den nærmeste node 

require 'sketchup'



$pair_array = Array.new
#$distance_sorted = Array.new
#gcode = Array.new

module CalculateNodePair

    def self.start

        puts "starting"
        

        t1 = Time.now

        
        #Initiate all the lines as class objects with the coordiantes for every pair as individual variables.

        4.times do 
      
            puts " "
            puts "newpair"
            test1 = Geom::Point3d.new(20 + Random.rand(110),20 + Random.rand(110),0)
            test2 = Geom::Point3d.new(20 + Random.rand(110),20 + Random.rand(110),0)
            node = NodePair.new(test1,test2, "1")

            $nodes << node

            puts "Point 1: #{node.point1}"
            puts "Point 2: #{node.point2}"

        end

        

        t2 = Time.now
             
        puts """Time: #{t2-t1} seconds."

    end


    def self.draw_lines

        puts "Drawing lines"

        $nodes.each do |node|

            puts "Point 1: #{node.point1}"
            puts "Point 2: #{node.point2}"

            Sketchup.active_model.entities.add_line(node.point1, node.point2)

        end

    end

    def self.draw_ordered_lines

        puts """Drawing lines"""
        
        $distance_sorted.compact!
        

        $distance_sorted.each do |node|

            puts "Route : G#{node.gcode}  #{node.point1}   --> #{node.point2}"""

            
            Sketchup.active_model.entities.add_line(node.point1, node.point2)

        end

    end




    def self.distdetermin
        
        $distance_sorted.push($nodes[0])
        
        limit = $nodes.size
        x = 0
        while x < limit
            x += 1
            $nodes.compact!        # removes all NIL elements in array
           
            
            
            for j in $nodes do

                i = $nodes[0]
                d1 = 0
                d2 = 0
                
                if j == i 
               
                else
                    
                    travel_point1 = nil
                    travel_point2 = nil

                    if i.start_point == 2
                        
                        puts "starting point 2"""

                        travel_point1 = i.point1
                        
                        d1 = i.point1.distance(j.point1)

                        Sketchup.active_model.entities.add_line(i.point1, j.point1)
                        
                        d2 = i.point1.distance(j.point2)
                        
                        Sketchup.active_model.entities.add_line(i.point1, j.point2)
                        
                        
                    else

                        puts "starting point 1"""
                           
                        travel_point1 = i.point2

                        d1 = i.point2.distance(j.point1)
                        
                        Sketchup.active_model.entities.add_line(i.point2, j.point1)
                        
                        d2 = i.point2.distance(j.point2)

                        
                        Sketchup.active_model.entities.add_line(i.point2, j.point2)
                    end
                    
                    if d1 <= d2
                       
                        j.start_point = 1
                        j.distance = d1
                        
                        puts "Does this happen???"
                        puts"d1 ---->> #{d1} < #{d2}"
                        
                    else
                        
                        j.start_point = 2
                        j.distance = d2

                        puts "Or this happen???"
                        puts"d2 ---->> #{d2} < #{d1}"
                        
                    end

                end

            end
            
            puts ""
            puts" #{d2} || #{d1}"
            puts ""

            $nodes.shift                                               # Removed the tested index
            
            $nodes.sort! { |x,y| x.distance <=> y.distance }             # Sort the array according to the distance meassured

            if $nodes[0].start_point == 1
            
                travel_point2 = $nodes[0].point1
            else
                travel_point2 = $nodes[0].point2
            end
            
            movenode = NodePair.new(travel_point1, travel_point2, 0)
            
            $distance_sorted.push(movenode)
            
            $distance_sorted.push($nodes[0])                             # Pushes the arranged lines to distance sorted array
            
                       
            
        end 


    end

end

class NodePair
        attr_accessor :point1, :point2, :placed, :start_point, :x, :y, :z, :a, :b, :gcode, :distance, :string
    
    def initialize(point1, point2, gcode)
   
        @point1 = Geom::Point3d.new(point1)
        @point2 = Geom::Point3d.new(point2)
        @gcode = gcode
        
        
        puts "#{@point1} -> #{@point2} -> #{@gcode}"
        puts""
        
        

        
        # String der skriver gcode med relative værdier

        
        
    end
   

        @distance = 0
        @start_point = 1

    
   
end

