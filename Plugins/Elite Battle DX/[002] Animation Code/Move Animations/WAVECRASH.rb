#-------------------------------------------------------------------------------
# WATERFALL
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:WATERFALL) do
  EliteBattle.playMoveAnimation(:WAVECRASH, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
#-------------------------------------------------------------------------------
#  WAVECRASH
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:WAVECRASH) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  frame = []
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb614_bg_9")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  pbSEPlay("Anim/Bubble2",60)
  for j in 0...16
    fp["f#{j}"] = Sprite.new(@viewport)
  	rndNote = rand(0..4)
  	if rndNote == 0
  		fp["f#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb618")
  	elsif rndNote == 1 || rndNote == 4
  		fp["f#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb618_2")
  	elsif rndNote == 2
  		fp["f#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb618_3")
  	elsif rndNote == 3
  		fp["f#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb618_4")
  	end
    fp["f#{j}"].ox = fp["f#{j}"].bitmap.width/2
    fp["f#{j}"].oy = fp["f#{j}"].bitmap.height/2
    fp["f#{j}"].x = @userSprite.x + rand(-64...64)
    fp["f#{j}"].y = @userSprite.y + rand(-16...16)
    fp["f#{j}"].visible = false
    fp["f#{j}"].z = @userSprite.z + 1
    frame.push(0)
  end
  # animation start
  pbSEPlay("Anim/water2")
  pbSEPlay("Anim/Bubble2")
  @sprites["battlebg"].defocus
  for i in 0...48
    for j in 0...16
      next if j>(i/2)
      fp["f#{j}"].visible = true
      fp["f#{j}"].y -= 8*@userSprite.zoom_y
      fp["f#{j}"].opacity -= 32 if frame[j] >= 8
      frame[j] += 1
    end
    fp["bg"].opacity += 8 if i >= 32
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/water3")
  @vector.set(vector)
  @scene.wait(16,true)
  cx, cy = @targetSprite.getCenter
  fp["flare"] = Sprite.new(@viewport)
  fp["flare"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb622_2")
  fp["flare"].ox = fp["flare"].bitmap.width/2
  fp["flare"].oy = fp["flare"].bitmap.height/2
  fp["flare"].x = cx
  fp["flare"].y = cy
  fp["flare"].zoom_x = @targetSprite.zoom_x
  fp["flare"].zoom_y = @targetSprite.zoom_y
  fp["flare"].z = @targetSprite.z
  fp["flare"].opacity = 0
  for j in 0...3
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_3")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].x = cx - 32 + rand(64)
    fp["#{j}"].y = cy - 32 + rand(64)
    fp["#{j}"].z = @targetSprite.z + 1
    fp["#{j}"].visible = false
    fp["#{j}"].zoom_x = @targetSprite.zoom_x
    fp["#{j}"].zoom_y = @targetSprite.zoom_y
  end
  @targetSprite.color = Color.new(0,0,0,0)
  for i in 0...64
    ax, ay = @targetSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    fp["bg"].opacity += 16 if fp["bg"].opacity < 255 && i < 32
    fp["bg"].color.alpha -= 32 if fp["bg"].color.alpha > 0
    fp["flare"].opacity += 32*(i < 8 ? 1 : -1)
    fp["flare"].angle += 32
    pbSEPlay("EBDX/Anim/fire1",80) if i == 8
    for j in 0...3
      next if i < 12
      next if j>(i-12)/4
      fp["#{j}"].visible = true
      fp["#{j}"].opacity -= 16
      fp["#{j}"].angle += 16
      fp["#{j}"].zoom_x += 0.1
      fp["#{j}"].zoom_y += 0.1
    end
    if i >= 48
      fp["bg"].opacity -= 16
      @targetSprite.color.alpha -= 16
    else
      @targetSprite.color.alpha += 16 if @targetSprite.color.alpha < 192
    end
    @targetSprite.anim = true
    @scene.wait
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
