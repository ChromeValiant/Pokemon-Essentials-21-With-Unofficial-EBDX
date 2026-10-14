#-------------------------------------------------------------------------------
#  SHIFTGEAR
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SHIFTGEAR) do | args |
  EliteBattle.playMoveAnimation(:GEARGRIND, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end

#-------------------------------------------------------------------------------
#  Gear up
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:GEARUP) do | args |
  EliteBattle.playMoveAnimation(:GEARGRIND, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end

#-------------------------------------------------------------------------------
#  Gear Grind
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:GEARGRIND) do
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  fp = {}
  factor = @targetIsPlayer ? 2 : 1.5
  shake = 8
  #
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  for i in 0...2
	  fp["gear#{i}"] = Sprite.new(@viewport)
	  fp["gear#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebgear")
	  fp["gear#{i}"].ox = fp["gear#{i}"].bitmap.width/2
	  fp["gear#{i}"].oy = fp["gear#{i}"].bitmap.height/2
	  fp["gear#{i}"].angle = 180
	  fp["gear#{i}"].zoom = @targetIsPlayer ? 2 : 1.5
	  fp["gear#{i}"].opacity = 0
	  fp["gear#{i}"].z = @targetSprite.z + 100
  end

  # set up animation
  @scene.wait(5,true)
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end

  for i in 0...2
	  fp["gear#{i}"].x, fp["gear#{i}"].y = @targetSprite.getCenter(true)
	  fp["gear#{i}"].x += 60 * factor* (i==0 ? -1 : 1)
	  fp["gear#{i}"].y += 20* factor* (i==0 ? 1 : 0)
  end
  #
  # set up animation
  @scene.wait(5,true)
  #
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  #
  for i in 0...50
  	for m in 0...2
  		fp["gear#{m}"].opacity += 16
      h = m==1 ? -1 : 1
      h = h*1.5  if @targetIsPlayer
      fp["gear#{m}"].x += 5*h if i < 10 #|| (25<=i && i< 35)
      pbSEPlay("EBDX/anim/Iron5",85) if i == 10 || i == 31
    	fp["gear#{m}"].angle += 10* ((m == 1) ? -1 : 1)
      #fp["gear#{m}"].x -= 5*h if (15<=i && i< 25) || (40<=i && i< 50)
  	end
    if i >= 20
      @targetSprite.ox += shake
      shake = -8 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 8 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait(1,true)
  end
  16.times do
    fp["bg"].opacity -= 20
    	for m in 0...2
    		fp["gear#{m}"].opacity -= 16
    	end
    @scene.wait(1,true)
  end
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
