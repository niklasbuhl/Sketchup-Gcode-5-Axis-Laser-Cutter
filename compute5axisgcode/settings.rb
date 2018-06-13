# ---

# Setup

# --- LASER ---

$laserFocalPoint = 167.mm # away from head
$laserFocalPercent = 100 # % (0 = top, 100 = bottom of face)

# --- MACHINE LIMITATIONS ---

$laserFeedrate = 800
$laserCuttingFeedrate = 150
$laserZFeedrateLimit = 400

$laserIntensity = 1


# --- GCODE ---
$gcodeDecimals = 4
$gcodeAngleDecimals = 2

# --- TABLE PHYSICAL BOUNDARIES ---

$tableWidth = 800.mm #(x-axis)
$tableDepth = 400.mm #(y-axis)
$tableHeight = 200.mm #(z-axis)
$laserStartX = 0.mm
$laserStartY = 0.mm
$laserStartZ = 167.mm

# --- INVERTING AXES ---

# Around X-axis
$invertAngleA = false

# Around Y-axis
$invertAngleB = false

$invertAxisX = false
$invertAxisY = false
$invertAxisZ = false

$switchAxisXY = false


# --- SKETCHUP DRAWING

$drawRaytest = false
$drawLaserCut = true


# --- DEBUGGING ---

# Test Printing without Z-Axis
$testPrintingWithoutZaxis = false

# Analyse Model
$debugAnalyseModel = false

# Analyse Faces
$debugAnalyseFaces = false

# Calculate Cutting Strategy
$debugClearCutRayArray = true
$debugRaytest = false
$debugCalculateCuttingStrategy = false
$debugStrategy1 = false
$debugStrategy2 = false
$debugStrategy2rays = false
$debugStrategy3 = false
$debugStrategy3rays = false
$debugLaserCut = false
$debugCalculateABangle = false

# Calculate Path
$debugGCode = false
$debugCalculateTrajectory = false
$debugGCodeRelative = false
$debugGCodeString = false
$debugGCodeAngle = false
$debugGCodeDraw = false
$debugFinalGCode = false
$debugPathAlgorithm = false

# Export GCode
$debugExportGCode = false

# Viften
$debugViften = false
