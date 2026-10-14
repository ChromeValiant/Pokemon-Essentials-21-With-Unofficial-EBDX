#-------------------------------------------------------------------------------
#  Aura Wheel
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:AURAWHEEL) do | args |
  withvector = true
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  @scene.wait(8,true)
  fp = {}
  type = :ELECTRIC
  @battlers[@userIndex].moves.each { |m| type = m.calcType if m.id == :AURAWHEEL }
  if type == :ELECTRIC
    color= Color.new(244,220,61,230)
    element = "eb069_2"
  else
    color = Color.new(91,87,95,230)
    element = "eb069_2_4"
  end
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,color)
  fp["bg"].opacity = 0
  r = (@userIsPlayer) ? 100 : 90
  cx, cy = @userSprite.getCenter(true)
  for i in 0...10
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/#{element}")
    fp["#{i}"].src_rect.set(0,0,98,430)
    fp["#{i}"].ox = fp["#{i}"].src_rect.width/2
    fp["#{i}"].oy = fp["#{i}"].src_rect.height
    fp["#{i}"].x = cx + r* Math.cos(36*i)
    fp["#{i}"].zoom_x = 0.2
    fp["#{i}"].zoom_y = 0.2
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
    pbSEPlay("EBDX/Anim/Electric1",100) if i == 4 || i == 20 || i == 36 || i == 52 
    @userSprite.still
    for j in 0...10
      x = fp["#{j}"].x
      y = fp["#{j}"].y
      fp["#{j}"].x = cx + Math.cos(3)*(x - cx) - Math.sin(3)*(y - cy)
      fp["#{j}"].y = cy + Math.sin(3)*(x - cx) + Math.cos(3)*(y - cy)
      fp["#{j}"].y += 10
      fp["#{j}"].angle = -Math.atan(1.0*(fp["#{j}"].y-cy)/(fp["#{j}"].x-cx))*(180.0/Math::PI)
      if j > i/3 
        fp["#{j}"].opacity += 15 if i < 60
        fp["#{j}"].src_rect.x = 98*rand(3)
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
  EliteBattle.playMoveAnimation(:TACKLE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
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