#-------------------------------------------------------------------------------
#  LOVETAP
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:LOVETAP) do
    EliteBattle.playMoveAnimation(:SNUGGLE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
#-------------------------------------------------------------------------------
#  COVET
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:COVET) do
  EliteBattle.playMoveAnimation(:SNUGGLE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  SNUGGLE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SNUGGLE) do
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(20,true)
  EliteBattle.playMoveAnimation(:TACKLE, @scene, @userIndex, @targetIndex, @hitNum, true, nil, false)
  fp = {}
  # set up animation
  @scene.wait(5,true)
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  dx = []
  dy = []
  t = 2
  for j in 0..t
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb636_2")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].x = cx + 20 if j == 0
    fp["#{j}"].x = cx - 20 if j == 1
	fp["#{j}"].x = cx      if j == 2
    fp["#{j}"].y = cy - 40 if j < 2
    fp["#{j}"].y = cy - 10 if j == 2
    fp["#{j}"].z = @targetSprite.z
    fp["#{j}"].visible = false
    z = [0.5,1,0.75][rand(3)]
    fp["#{j}"].zoom_x = z
    fp["#{j}"].zoom_y = z
  end
  # start animation
  for i in 0...30
	pbSEPlay("Anim/Love",100) if i == 3 || i == 9 || i == 15
    for j in 0..t
      next if j>(i*2)
	  next if i <= 5 && j == 1
      fp["#{j}"].visible = true
      if i > 20
        fp["#{j}"].opacity -= 32
      else
		if fp["#{j}"].zoom <= 1.5
			fp["#{j}"].zoom += 0.1
		else
		    fp["#{j}"].opacity -= 32
		end
      end
    end
    @scene.wait
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
