#-------------------------------------------------------------------------------
#  Blaze Kick
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:BLAZEKICK) do
  EliteBattle.playMoveAnimation(:FIREPUNCH, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
#-------------------------------------------------------------------------------
#  Fire Punch
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FIREPUNCH) do | args |
  kick = args[0]; kick = false if kick.nil?
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(130,52,42))
  fp["bg"].opacity = 0
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb136")
    fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 50
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)/2
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)/2
    rndx.push(rand(144))
    rndy.push(rand(144))
  end
  fp["hit"] = Sprite.new(@viewport)
  fp["hit"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb#{kick ? 137 : 108}")
  fp["hit"].ox = fp["hit"].bitmap.width/2
  fp["hit"].oy = fp["hit"].bitmap.height/2
  fp["hit"].opacity = 0
  fp["hit"].z = 40
  fp["hit"].angle = 180
  fp["hit"].zoom_x = @targetIsPlayer ? 6 : 4
  fp["hit"].zoom_y = @targetIsPlayer ? 6 : 4
  fp["hit"].tone = Tone.new(48,16,6)
  shake = 4
  # start animation
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  pbSEPlay("Anim/fog2", 75)
  @sprites["battlebg"].defocus
  for i in 0...72
    cx, cy = @targetSprite.getCenter(true)
    fp["hit"].x = cx
    fp["hit"].y = cy
    fp["hit"].angle -= 45 if i < 40
    fp["hit"].zoom_x -= @targetIsPlayer ? 0.2 : 0.15 if i < 40
    fp["hit"].zoom_y -= @targetIsPlayer ? 0.2 : 0.15 if i < 40
    fp["hit"].opacity += 8 if i < 40
    if i >= 40
      fp["hit"].tone = Tone.new(255,255,255) if i == 40
      fp["hit"].tone.all -= 25.5
      fp["hit"].opacity -= 25.5
    end
    pbSEPlay("Anim/Fire3") if i==40
    for j in 0...12
      next if i < 40
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        fp["#{j}"].x = cx
        fp["#{j}"].y = cy
      end
      x2 = cx - 72*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 72*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.2
      fp["#{j}"].y += (y2 - y0)*0.2
      fp["#{j}"].src_rect.x += 53 if i%2==0
      fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["#{j}"].opacity -= 16
        fp["#{j}"].tone.gray += 16
        fp["#{j}"].tone.red -= 4; fp["#{j}"].tone.green -= 4; fp["#{j}"].tone.blue -= 4
        fp["#{j}"].zoom_x -= 0.005
        fp["#{j}"].zoom_y += 0.01
      else
        fp["#{j}"].opacity += 45
      end
    end
    fp["bg"].opacity += 4 if  i < 40
    if i >= 40
      if i >= 56
        @targetSprite.tone.red -= 3*2
        @targetSprite.tone.green += 1.5*2
        @targetSprite.tone.blue += 3*2
        fp["bg"].opacity -= 10
      else
        @targetSprite.tone.red += 3*2 if @targetSprite.tone.red < 48*2
        @targetSprite.tone.green -= 1.5*2 if @targetSprite.tone.green > -24*2
        @targetSprite.tone.blue -= 3*2 if @targetSprite.tone.blue > -48*2
      end
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
