#-------------------------------------------------------------------------------
#  Helping hand
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:HELPINGHAND) do
  @userIsPlayer ? @vector.set(@scene.getRealVector(0, @userIsPlayer)) : @vector.set(@scene.getRealVector(2, @userIsPlayer))
  fp = {}
  factor = @targetIsPlayer ? 2 : 1.5
  #
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  for i in 0...2
	  fp["hand#{i}"] = Sprite.new(@viewport)
	  fp["hand#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebhelpinghand_#{i}")
	  fp["hand#{i}"].ox = 25
	  fp["hand#{i}"].oy = 25
	  fp["hand#{i}"].zoom = @targetIsPlayer ? 4 : 3
	  fp["hand#{i}"].opacity = 0
	  fp["hand#{i}"].z = @targetSprite.z + 100
  end

  # set up animation
  @scene.wait(5,true)
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end

  for i in 0...2
	  fp["hand#{i}"].x, fp["hand#{i}"].y = @targetSprite.getCenter(true)
	  fp["hand#{i}"].x += 40 * factor* (i==0 ? -1 : 1)
	  fp["hand#{i}"].y -= 80
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
  		fp["hand#{m}"].opacity += 16
      h = m==1 ? -1 : 1
      h = h*1.5  if @targetIsPlayer
      fp["hand#{m}"].x += 5*h if i < 10 || (25<=i && i< 35)
      pbSEPlay("clap",85) if i == 10 || i == 35
      #5 frame pause between clap
      fp["hand#{m}"].x -= 5*h if (15<=i && i< 25) || (40<=i && i< 50)
  	end
    @scene.wait(1,true)
  end
  16.times do
    fp["bg"].opacity -= 20
    	for m in 0...2
    		fp["hand#{m}"].opacity -= 16
    	end
    @scene.wait(1,true)
  end
  @vector.reset
  pbDisposeSpriteHash(fp)
end
