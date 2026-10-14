#-------------------------------------------------------------------------------
#  FLAMEWHEEL
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FLAMEWHEEL) do | args |
  EliteBattle.playMoveAnimation(:FLAMECHARGE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  FLAMECHARGE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FLAMECHARGE) do | args |
  withvector = true
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  @scene.wait(8,true)
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(130,52,42))
  fp["bg"].opacity = 0
  r = (@userIsPlayer) ? 100 : 90
  cx, cy = @userSprite.getCenter(true)
  for i in 0...10
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb136")
    fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 101
    fp["#{i}"].x = cx + r* Math.cos(36*i)
    fp["#{i}"].y = cy + r* Math.sin(36*i)
    fp["#{i}"].y += 10
    fp["#{i}"].z = @userSprite.z + 1
    fp["#{i}"].oy = 101
    fp["#{i}"].opacity = 0
  end
  # set up animation
  @scene.wait(5,true)
  # charge
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  idx =  0 # counter
  dir = -1 # direction
  xOrigin = @userSprite.ox
  for i in 0...96
    pbSEPlay("EBDX/Anim/fire1",100) if i == 4
    @userSprite.still
    for j in 0...10
      x = fp["#{j}"].x
      y = fp["#{j}"].y
      fp["#{j}"].x = cx + Math.cos(3)*(x - cx) - Math.sin(3)*(y - cy)
      fp["#{j}"].y = cy + Math.sin(3)*(x - cx) + Math.cos(3)*(y - cy)
      fp["#{j}"].y += 10
      if j > i/3 
        fp["#{j}"].opacity += 15 if i < 60
        fp["#{j}"].src_rect.x += 53 if i%4==0
        fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
      end
    end
    if i > 60
      for j in 0...10
        fp["#{j}"].opacity -= 15
      end
    end
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/fire2",100)
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer)) if withvector
  @scene.wait(10,true)
  EliteBattle.playCommonAnimation(:BURN, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  @userSprite.ox = @userSprite.bitmap.width/2
  #frame.dispose
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end