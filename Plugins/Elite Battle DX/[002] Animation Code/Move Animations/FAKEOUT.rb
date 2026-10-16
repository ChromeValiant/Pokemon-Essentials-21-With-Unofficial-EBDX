#-------------------------------------------------------------------------------
#  Fake Out
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FAKEOUT) do | args |
  withvector, shake = *args; withvector = true if withvector.nil?; shake = false if shake.nil?
  withvector = true
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  factor = @targetIsPlayer ? 2 : 1.5
  fp = {}
  rndx = []
  rndy = []
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
  # charge
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  shake = 30
  idx =  0 # counter
  dir = -1 # direction
  ports = 25
  xOrigin = @userSprite.ox
  for i in 0...ports
    pbSEPlay("EBDX/Anim/move1",80) if i == 4
    @userSprite.still
  	#default movement
  	if i == 3
  		@userSprite.ox += shake
  	end
    if i.between?(4,ports)
  		if dir == -1 #move left
  			@userSprite.ox -= shake
  		else # move right
  		    @userSprite.ox += shake
  		end
  	  idx += 1
  	  if idx == 2
    		idx = 0
    		dir = dir * -1
  	  end
    end
  	if i.between?(14,ports)
  		@userSprite.opacity -= 35
  	end

    @scene.wait(1,true)
  end
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer)) if withvector
  @scene.wait(10,true)
  for i in 0...2
	  fp["hand#{i}"].x, fp["hand#{i}"].y = @targetSprite.getCenter(true)
	  fp["hand#{i}"].x += 40 * factor* (i==0 ? -1 : 1)
	  fp["hand#{i}"].y -= 80
  end

  shake = 5
  for i in 0...25
    for m in 0...2
      fp["hand#{m}"].opacity += 16
      h = m==1 ? -1 : 1
      h = h*1.5  if @targetIsPlayer
      fp["hand#{m}"].x += 10*h if i < 5
      pbSEPlay("EBDX/Anim/normal1",80) if i == 5
      #5 frame pause between clap
      fp["hand#{m}"].x -= 10*h if (13<=i && i< 18)
    end
    if i >= 6
      @targetSprite.ox += shake
      shake = (i < 15) ? -5 : -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = (i < 15) ? 5 : 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait(1,true)
  end
  16.times do
    fp["bg"].opacity -= 20
  	for m in 0...2
  		fp["hand#{m}"].opacity -= 16
  	end
	  @userSprite.opacity += 20
    @scene.wait(1,true)
  end
  @userSprite.ox = @userSprite.bitmap.width/2
  #frame.dispose
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
