#-------------------------------------------------------------------------------
#  POWDERSNOW
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:POWDERSNOW) do
  EliteBattle.playMoveAnimation(:FREEZEDRY, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
#-------------------------------------------------------------------------------
#  FROSTCALL
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FROSTCALL) do
  EliteBattle.playMoveAnimation(:FREEZEDRY, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end

#-------------------------------------------------------------------------------
#  Icy Wind
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ICYWIND) do
  # set up animation
  fp = {}
  rndx = [[],[]]; rndy = [[],[]]
  irndx = [[],[]]; irndy = [[],[]]
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(100,128,142))
  fp["bg"].opacity = 0
  for m in 0...@opposingTargets.length
    for i in 0...8
      fp["#{m}#{i}"] = Sprite.new(@viewport)
      fp["#{m}#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb250")
      fp["#{m}#{i}"].ox = fp["#{m}#{i}"].bitmap.width/2
      fp["#{m}#{i}"].oy = fp["#{m}#{i}"].bitmap.width/2
      fp["#{m}#{i}"].opacity = 0
      fp["#{m}#{i}"].z = (@targetIsPlayer ? 29 : 19)
      rndx[m].push(rand(64))
      rndy[m].push(rand(64))
    end
  end
  for m in 0...@opposingTargets.length
    next if !@opposingTargets[m] || @opposingTargets[m].disposed? || @opposingTargets[m].fainted || !@opposingTargets[m].visible
    for i in 0...8
      fp["i#{m}#{i}"] = Sprite.new(@viewport)
      fp["i#{m}#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb248")
      fp["i#{m}#{i}"].src_rect.set(0,0,26,42)
      fp["i#{m}#{i}"].ox = 13
      fp["i#{m}#{i}"].oy = 21
      fp["i#{m}#{i}"].opacity = 0
      fp["i#{m}#{i}"].z = (@targetIsPlayer ? 29 : 19)
      fp["i#{m}#{i}"].zoom_x = (@opposingTargets[m].zoom_x)/2
      fp["i#{m}#{i}"].zoom_y = (@opposingTargets[m].zoom_y)/2
      irndx[m].push(rand(128))
      irndy[m].push(rand(128))
    end
  end
  shake = [2,2]
  @sprites["battlebg"].defocus
  # start animation
  for i in 0...102
    for m in 0...@opposingTargets.length
      next if !@opposingTargets[m] || @opposingTargets[m].disposed? || @opposingTargets[m].fainted || !@opposingTargets[m].visible
      for j in 0...8
        if fp["#{m}#{j}"].opacity == 0 && fp["#{m}#{j}"].tone.gray == 0
          fp["#{m}#{j}"].zoom_x = @userSprite.zoom_x
          fp["#{m}#{j}"].zoom_y = @userSprite.zoom_y
          cx, cy = @userSprite.getAnchor
          fp["#{m}#{j}"].x = cx
          fp["#{m}#{j}"].y = cy
        end
        cx, cy = @opposingTargets[m].getCenter(true)
        next if j>(i/4)
        x2 = cx - 32*@opposingTargets[m].zoom_x + rndx[m][j]*@opposingTargets[m].zoom_x
        y2 = cy - 32*@opposingTargets[m].zoom_y + rndy[m][j]*@opposingTargets[m].zoom_y
        x0 = fp["#{m}#{j}"].x
        y0 = fp["#{m}#{j}"].y
        fp["#{m}#{j}"].x += (x2 - x0)*0.1
        fp["#{m}#{j}"].y += (y2 - y0)*0.1
        fp["#{m}#{j}"].zoom_x -= (fp["#{m}#{j}"].zoom_x - @opposingTargets[m].zoom_x)*0.1
        fp["#{m}#{j}"].zoom_y -= (fp["#{m}#{j}"].zoom_y - @opposingTargets[m].zoom_y)*0.1
        fp["#{m}#{j}"].angle += 2
        if (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
          fp["#{m}#{j}"].opacity -= 8
          fp["#{m}#{j}"].tone.gray += 8
          fp["#{m}#{j}"].angle += 2
        else
          fp["#{m}#{j}"].opacity += 12
        end
      end
    end
    if i >= 82
      fp["bg"].opacity -= 7
    else
      fp["bg"].opacity += 2 if fp["bg"].opacity < 255*0.5
    end
    pbSEPlay("Anim/Ice7", 80) if i == 96
    pbSEPlay("Anim/Wind8", 70) if i == 12
    if i >= 46
      for m in 0...@opposingTargets.length
        next if !@opposingTargets[m] || @opposingTargets[m].disposed? || @opposingTargets[m].fainted || !@opposingTargets[m].visible
        cx, cy = @opposingTargets[m].getCenter(true)
        if i >= 132
          @opposingTargets[m].tone.red -= 4.8
          @opposingTargets[m].tone.green -= 4.8
          @opposingTargets[m].tone.blue -= 4.8
        else
          @opposingTargets[m].tone.red += 4.8 if @opposingTargets[m].tone.red < 96
          @opposingTargets[m].tone.green += 4.8 if @opposingTargets[m].tone.green < 96
          @opposingTargets[m].tone.blue += 4.8 if @opposingTargets[m].tone.blue < 96
        end
        @opposingTargets[m].ox += shake[m]
        shake[m] = -2 if @opposingTargets[m].ox > @opposingTargets[m].bitmap.width/2 + 2
        shake[m] = 2 if @opposingTargets[m].ox < @opposingTargets[m].bitmap.width/2 - 2
        @opposingTargets[m].still
        for k in 0...8
          if fp["i#{m}#{k}"].opacity == 0 && fp["i#{m}#{k}"].src_rect.x == 0
            fp["i#{m}#{k}"].x = cx - 64*@opposingTargets[m].zoom_x + irndx[m][k]*@opposingTargets[m].zoom_x
            fp["i#{m}#{k}"].y = cy - 64*@opposingTargets[m].zoom_y + irndy[m][k]*@opposingTargets[m].zoom_y
          end
          fp["i#{m}#{k}"].src_rect.x += 26 if i%4==0 && fp["i#{m}#{k}"].opacity >= 255
          fp["i#{m}#{k}"].src_rect.x = 78 if fp["i#{m}#{k}"].src_rect.x > 78
          if fp["i#{m}#{k}"].src_rect.x==78
            fp["i#{m}#{k}"].opacity -= 24
            fp["i#{m}#{k}"].zoom_x += 0.02
            fp["i#{m}#{k}"].zoom_y += 0.02
          elsif fp["i#{m}#{k}"].opacity >= 255
            fp["i#{m}#{k}"].opacity -= 24
            pbSEPlay("Anim/Ice1",50)
          else
            fp["i#{m}#{k}"].opacity += 45 if (i-96)/2 > k
          end
        end
      end
    end
    @vector.set(EliteBattle.get_vector(:DUAL)) if i == 24
    @vector.inc = 0.1 if i == 24
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  for m in 0...@opposingTargets.length
    next if !@opposingTargets[m] || @opposingTargets[m].disposed? || @opposingTargets[m].fainted || !@opposingTargets[m].visible
    @opposingTargets[m].ox = @opposingTargets[m].bitmap.width/2
    @opposingTargets[m].tone = Tone.new(0,0,0,0)
  end
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end


#-------------------------------------------------------------------------------
#  FREEZEDRY
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FREEZEDRY) do
  # set up animation
  fp = {}
  rndx = []; rndy = []
  irndx = []; irndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(100,128,142))
  fp["bg"].opacity = 0
  for i in 0...8
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb250")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.width/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = (@targetIsPlayer ? 29 : 19)
    rndx.push(rand(64))
    rndy.push(rand(64))
  end
  for i in 0...8
    fp["i#{i}"] = Sprite.new(@viewport)
    fp["i#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb248")
    fp["i#{i}"].src_rect.set(0,0,26,42)
    fp["i#{i}"].ox = 13
    fp["i#{i}"].oy = 21
    fp["i#{i}"].opacity = 0
    fp["i#{i}"].z = (@targetIsPlayer ? 29 : 19)
    fp["i#{i}"].zoom_x = (@targetSprite.zoom_x)/2
    fp["i#{i}"].zoom_y = (@targetSprite.zoom_y)/2
    irndx.push(rand(128))
    irndy.push(rand(128))
  end
  shake = 2
  @sprites["battlebg"].defocus
  # start animation
  for i in 0...102 
    for j in 0...8
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        fp["#{j}"].zoom_x = @userSprite.zoom_x
        fp["#{j}"].zoom_y = @userSprite.zoom_y
        cx, cy = @userSprite.getAnchor
        fp["#{j}"].x = cx
        fp["#{j}"].y = cy
      end
      cx, cy = @targetSprite.getCenter(true)
      next if j>(i/4)
      x2 = cx - 32*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 32*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].zoom_x -= (fp["#{j}"].zoom_x - @targetSprite.zoom_x)*0.1
      fp["#{j}"].zoom_y -= (fp["#{j}"].zoom_y - @targetSprite.zoom_y)*0.1
      fp["#{j}"].angle += 2
      if (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
        fp["#{j}"].opacity -= 8
        fp["#{j}"].tone.gray += 8
        fp["#{j}"].angle += 2
      else
        fp["#{j}"].opacity += 12
      end
    end
    if i >= 82
      fp["bg"].opacity -= 7
    else
      fp["bg"].opacity += 2 if fp["bg"].opacity < 255*0.5
    end
    pbSEPlay("Anim/Ice7", 80) if i == 96
    pbSEPlay("Anim/Wind8", 70) if i == 12
    if i >= 46
      if i >= 132
        @targetSprite.tone.red -= 4.8
        @targetSprite.tone.green -= 4.8
        @targetSprite.tone.blue -= 4.8
      else
        @targetSprite.tone.red += 4.8 if @targetSprite.tone.red < 96
        @targetSprite.tone.green += 4.8 if @targetSprite.tone.green < 96
        @targetSprite.tone.blue += 4.8 if @targetSprite.tone.blue < 96
      end
      @targetSprite.ox += shake
      shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
      for k in 0...8
        if fp["i#{k}"].opacity == 0 && fp["i#{k}"].src_rect.x == 0
          fp["i#{k}"].x = cx - 64*@targetSprite.zoom_x + irndx[k]*@targetSprite.zoom_x
          fp["i#{k}"].y = cy - 64*@targetSprite.zoom_y + irndy[k]*@targetSprite.zoom_y
        end
        fp["i#{k}"].src_rect.x += 26 if i%4==0 && fp["i#{k}"].opacity >= 255
        fp["i#{k}"].src_rect.x = 78 if fp["i#{k}"].src_rect.x > 78
        if fp["i#{k}"].src_rect.x==78
          fp["i#{k}"].opacity -= 24
          fp["i#{k}"].zoom_x += 0.02
          fp["i#{k}"].zoom_y += 0.02
        elsif fp["i#{k}"].opacity >= 255
          fp["i#{k}"].opacity -= 24
          pbSEPlay("Anim/Ice1",50)
        else
          fp["i#{k}"].opacity += 45 if (i-96)/2 > k
        end
      end
    end
    @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer)) if i == 24
    @vector.inc = 0.1 if i == 24
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @targetSprite.tone = Tone.new(0,0,0,0)
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end