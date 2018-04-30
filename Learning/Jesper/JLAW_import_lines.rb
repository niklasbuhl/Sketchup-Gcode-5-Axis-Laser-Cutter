#----------------------------------------------------------------------------------------
require 'sketchup.rb'
require 'csv'
#require 'Math'

=begin

Script by Jacob Lawaetz, October 2017, JLAW@dtu.dk
From a .txt-file it creates the movement of the laser reference point + it draws the laser vectors
input file format is a .txt file consisting of lines of tab-separated values like this:

210.1411	131.10018	131.10018	45	-30.0571

where the numbers indicate:
X	Y	Z 	A 	B

X = X-coordinate of reference point in mm
Y = Y-coordinate of reference point in mm
Z = Z-coordinate of reference point in mm
A = rotation of laser head in A-direction in degrees
B = rotation of laser head in B-direction in degrees

The conversion between mm and inches caused some trouble, but seems to work correctly now

The script is based on a script called jimhami42_import_lines found here: 
https://sites.google.com/site/spirixcode/code

=end


#declaration of laser variables	
	
$Z0 = 200	# Z-value of reference point above origo in mm		@-symbol denotes global variable in ruby
$LD = 40 	# distance from mirror to bottom of lens in mm
$FL = 50 	# distance from bottom of lens to focus point in mm
$MT = 10	# material thickness in mm
$FD = 0		# Focus depth in material in %

print "Z0 = " + $Z0.to_s + " mm \n"
print "LD = " + $LD.to_s + " mm \n"
print "FL = " + $FL.to_s + " mm \n"
print "MT = " + $MT.to_s + " mm \n"
print "FD = " + $FD.to_s + " % \n"

$ref_to_focus = ($LD + $FL+ $FD*$MT) 

print "ref_to_focus = " + $ref_to_focus.to_s + "\n"

#----------------------------------------------------------------------------------------
module JLAW
  module ImportLines
# MAIN BODY -----------------------------------------------------------------------------

SKETCHUP_CONSOLE.show


    class  << self
      def import_lines()
        model = Sketchup.active_model

	filename = UI.openpanel("Select TXT File", "~", "Text Files|*.txt;||")
        data = File.open(filename,"r")
	
        x1,y1,z1,a1,b1 = data.gets.chomp.split("\t")


        x1 = (x1.to_f).mm 
        y1 = (y1.to_f).mm 
        z1 = (z1.to_f).mm 
	a1 = (a1.to_f)
	b1 = (b1.to_f) 


        while(t = data.gets)
          x,y,z,a,b = t.chomp.split("\t")
          x = (x.to_f).mm 
	  y = (y.to_f).mm 
          z = (z.to_f).mm
	  a = (a.to_f)
	  b = (b.to_f)	 
	
	  # prints the vector-coordinates of the path
	  print "x,y,z = " + x.to_s + "\t"+ y.to_s + "\t" + z.to_s + "\t"+"\n"		
	  print "x1,y1,z1 = " + x1.to_s + "\t"+ y1.to_s + "\t" + z1.to_s + "\t"+"\n"





	  # draw the path of the reference point		
	  # first a test to determine if the xyz point is 0,0,0. This could be done in a more elegant way in the while loop
	  if Geom::Vector3d.new(x,y,z).length > 0
            model.active_entities.add_edges([x1,y1,z1],[x,y,z])
	  end	


	  # vector calculating the orientation of the laser from a and b
	  laser_direction = Geom::Vector3d.new(-Math.tan(b.degrees).to_f, Math.tan(a.degrees).to_f, -1 )


	  print "\n" + "b = " + b.to_s + "\n"
	

	  # Note: to get the length of the vector without unit conversion between mm and inches, the .to_f is used

	  print "laser_direction = " + laser_direction.to_s + "\n"
	  print "laser_direction length = " + (laser_direction.length.to_f).to_s + "\n" 

	  
	  # the length of the vector must be equal to ref_to_focus
	  # each component of the vector must therefore be multiplied with a constant to obtain the required length
   	  
	  vector_scaling_factor = $ref_to_focus / laser_direction.length
	  
	 
	  print "vector_scaling_factor = " + vector_scaling_factor.to_s + "\n"

	  
	  laser_direction_scaled = Geom::Vector3d.new(laser_direction[0].mm*vector_scaling_factor, laser_direction[1].mm*vector_scaling_factor, laser_direction[2].mm*vector_scaling_factor)

	  print	"laser_direction_scaled = " + Geom::Vector3d.new(laser_direction[0]*vector_scaling_factor, laser_direction[1]*vector_scaling_factor, laser_direction[2]*vector_scaling_factor).to_s + "\n"
 	 
	
	  # the laser direction is drawn
	  # the if-sentence is a test to determine if the xyz point is 0,0,0. This could be done in a more elegant way in the while loop
	  if Geom::Vector3d.new(x,y,z).length > 0
	    model.active_entities.add_edges([x,y,z], (Geom::Point3d.new(x,y,z)).offset(laser_direction_scaled) )
	  end
	 
	  print "\n"

	  # preparing variables for next iteration of while loop
          x1 = x
          y1 = y
          z1 = z
        end
      end
      print "\n"	
    end


# MAIN BODY -----------------------------------------------------------------------------
    unless file_loaded?("JLAW_import_lines.rb")
      menu = UI.menu("PlugIns").add_item("Import Lines") { import_lines() }
    file_loaded("JLAW_import_lines.rb")
    end
# MAIN BODY -----------------------------------------------------------------------------
  end
end