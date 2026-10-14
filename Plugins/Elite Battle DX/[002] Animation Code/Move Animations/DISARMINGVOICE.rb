#-------------------------------------------------------------------------------
#  DISARMINGVOICE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:DISARMINGVOICE) do
  itself = (@userIndex==@targetIndex)
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  rndNote = 0
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(255,204,255))
  fp["bg"].opacity = 0
  for m in 0...@opposingTargets.length
    for i in 0...12
      fp["#{m}_#{i}"] = Sprite.new(@viewport)
      rndNote = rand(2)
      if rndNote == 0
        fp["#{m}_#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb617_9")
      else
        fp["#{m}_#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb617_10")
      end
      #fp["#{m}_#{i}"].src_rect.set(0,101*rand(3),53,101)
      fp["#{m}_#{i}"].src_rect.set(0,101*0,53,101)
      fp["#{m}_#{i}"].ox = 26
      fp["#{m}_#{i}"].oy = 101
      fp["#{m}_#{i}"].opacity = 0
      fp["#{m}_#{i}"].z = (@targetIsPlayer ? 29 : 19)
      rndx.push(rand(64))
      rndy.push(rand(64))
    end
  end
  shake = Array.new(@opposingTargets.length, 2)
  alternate = true
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...132
    for m in 0...@opposingTargets.length
      ax, ay = @userSprite.getAnchor
      cx, cy = @opposingTargets[m].getCenter(true)
      for j in 0...12
        if fp["#{m}_#{j}"].opacity == 0 && fp["#{m}_#{j}"].tone.gray == 0
          fp["#{m}_#{j}"].zoom_x = @userSprite.zoom_x
          fp["#{m}_#{j}"].zoom_y = @userSprite.zoom_y
          fp["#{m}_#{j}"].x = ax
          fp["#{m}_#{j}"].y = ay + 50*@userSprite.zoom_y
        end
        next if j>(i/4)
        x2 = cx - 32*@opposingTargets[m].zoom_x + rndx[j]*@opposingTargets[m].zoom_x
        y2 = cy - 32*@opposingTargets[m].zoom_y + rndy[j]*@opposingTargets[m].zoom_y + 50*@opposingTargets[m].zoom_y
        x0 = fp["#{m}_#{j}"].x
        y0 = fp["#{m}_#{j}"].y
        fp["#{m}_#{j}"].x += (x2 - x0)*0.1
        fp["#{m}_#{j}"].y += (y2 - y0)*0.1
        fp["#{m}_#{j}"].zoom_x -= (fp["#{m}_#{j}"].zoom_x - @opposingTargets[m].zoom_x)*0.1
        fp["#{m}_#{j}"].zoom_y -= (fp["#{m}_#{j}"].zoom_y - @opposingTargets[m].zoom_y)*0.1
        fp["#{m}_#{j}"].src_rect.x += 53 if i%4==0
        fp["#{m}_#{j}"].src_rect.x = 0 if fp["#{m}_#{j}"].src_rect.x >= fp["#{m}_#{j}"].bitmap.width
        if (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
          fp["#{m}_#{j}"].opacity -= 8
          fp["#{m}_#{j}"].tone.gray += 8
          fp["#{m}_#{j}"].tone.red -= 2; fp["#{m}_#{j}"].tone.green -= 2; fp["#{m}_#{j}"].tone.blue -= 2
          fp["#{m}_#{j}"].zoom_x -= 0.02
          fp["#{m}_#{j}"].zoom_y += 0.04
        else
          fp["#{m}_#{j}"].opacity += 12
        end
      end
    end
    fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.5
    pbSEPlay("Anim/DisarmingVoice",80) if i==0
    if i >= 96
      for m in 0...@opposingTargets.length
        @opposingTargets[m].ox += shake[m]
        shake[m] = -2 if @opposingTargets[m].ox > @opposingTargets[m].bitmap.width/2 + 2
        shake[m] = 2 if @opposingTargets[m].ox < @opposingTargets[m].bitmap.width/2 - 2
        @opposingTargets[m].still
      end
    end
    @vector.set(EliteBattle.get_vector(:DUAL)) if i == 24
    @vector.inc = 0.1 if i == 24
    @scene.wait(1,true)
  end
  20.times do
    # @targetSprite.tone.red -= 2.4*2
    # @targetSprite.tone.green += 1.2*2
    # @targetSprite.tone.blue += 2.4*2
    for m in 0...@opposingTargets.length
      @opposingTargets[m].ox += shake[m]
      shake[m] = -1 if @opposingTargets[m].ox > @opposingTargets[m].bitmap.width/2 + 1
      shake[m] = 1 if @opposingTargets[m].ox < @opposingTargets[m].bitmap.width/2 - 1
      @opposingTargets[m].still
    end
    fp["bg"].opacity -= 15
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end

EliteBattle.defineMoveAnimation(:ALLURINGVOICE) do
  itself = (@userIndex==@targetIndex)
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  rndNote = 0
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(255,204,255))
  fp["bg"].opacity = 0
  for i in 0...16
    fp["#{i}"] = Sprite.new(@viewport)
	rndNote = rand(3)
	if rndNote == 0
		fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb619_7")
  elsif rndNote == 1
		fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb619_6")
	else
		fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb619")
	end
    #fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
    fp["#{i}"].src_rect.set(0,101*0,53,101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 101
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = (@targetIsPlayer ? 29 : 19)
    rndx.push(rand(64))
    rndy.push(rand(64))
  end
  shake = 2
  alternate = true
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...132
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...16
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        fp["#{j}"].zoom_x = @userSprite.zoom_x
        fp["#{j}"].zoom_y = @userSprite.zoom_y
        fp["#{j}"].x = ax
        fp["#{j}"].y = ay + 50*@userSprite.zoom_y
      end
      next if j>(i/4)
      x2 = cx - 32*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 32*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y + 50*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].zoom_x -= (fp["#{j}"].zoom_x - @targetSprite.zoom_x)*0.1
      fp["#{j}"].zoom_y -= (fp["#{j}"].zoom_y - @targetSprite.zoom_y)*0.1
      fp["#{j}"].src_rect.x += 53 if i%4==0
      fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
      if (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
        fp["#{j}"].opacity -= 8
        fp["#{j}"].tone.gray += 8
        fp["#{j}"].tone.red -= 2; fp["#{j}"].tone.green -= 2; fp["#{j}"].tone.blue -= 2
        fp["#{j}"].zoom_x -= 0.02
        fp["#{j}"].zoom_y += 0.04
      else
        fp["#{j}"].opacity += 12
      end
    end
    fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.5
    pbSEPlay("Anim/DisarmingVoice",80) if i==0
    if i >= 96
      @targetSprite.ox += shake
      shake = -2 if alternate
      shake = 2 if !alternate
      alternate = !alternate
      @targetSprite.still
    end
    @vector.set(EliteBattle.get_vector(:DUAL)) if i == 24
    @vector.inc = 0.1 if i == 24
    @scene.wait(1,true)
  end
  alternate = true
  20.times do
    # @targetSprite.tone.red -= 2.4*2
    # @targetSprite.tone.green += 1.2*2
    # @targetSprite.tone.blue += 2.4*2
    @targetSprite.ox += shake
    shake = -1 if alternate
    shake = 1 if !alternate
    alternate = !alternate
    @targetSprite.still
    fp["bg"].opacity -= 15
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end