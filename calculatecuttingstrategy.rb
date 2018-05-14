include 'sketchup'

module CalculateCuttingStrategy

  def GenerateCloneModel faceArrayClone

    # Add layer
    layer = $layers.add "Penetration Layer"

    # Change Layer
    $model.active_layer = layer

    # Generate face from each of the faces in the original model
    faceArrayClone.each do |faceArray|

      # Add the face to the active model in the clone
      tempFace = $entities.add_face(faceArray)

    end

  end

  def RemoveCloneModel

    Sketchup.active_model.layers.remove("Penetration Layer", true)

  end

  def CheckPenetration cuttingTrajectoryGeometry

    return true # No penetration

  end

  def GenerateStrategyA cuttingFace

    return cuttingTrajectoryGeometry

  end

  def GenerateStrategyB1 cuttingFace

    return cuttingTrajectoryGeometry

  end

  def GenerateStrategyB2 cuttingFace

    return cuttingTrajectoryGeometry

  end

  def GenerateStrategyC1 cuttingFace

    return cuttingTrajectoryGeometry

  end

  def GenerateStrategyC2 cuttingFace

    return cuttingTrajectoryGeometry

  end

  def GenerateStrategyD cuttingFace

    return cuttingTrajectoryGeometry

  end

end
