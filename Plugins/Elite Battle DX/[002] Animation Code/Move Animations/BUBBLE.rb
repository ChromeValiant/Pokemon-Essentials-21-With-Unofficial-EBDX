#-------------------------------------------------------------------------------
#  BUBBLE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:BUBBLE) do
  
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  rndNote = 0
  
  for m in 0...@opposingTargets.length
    for i in 0...10
      fp["#{m}_#{i}"] = Sprite.new(@viewport)
      rndNote = rand(0..4)
      if rndNote == 0
        fp["#{m}_#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb618")
      elsif rndNote == 1 || rndNote == 4
        fp["#{m}_#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb618_2")
      elsif rndNote == 2
        fp["#{m}_#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb618_3")
      elsif rndNote == 3
        fp["#{m}_#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb618_4")
      end
      #fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
      fp["#{m}_#{i}"].src_rect.set(0,101*0,53,101)
      fp["#{m}_#{i}"].ox = 26
      fp["#{m}_#{i}"].oy = 101
      fp["#{m}_#{i}"].opacity = 0
      fp["#{m}_#{i}"].z = (@targetIsPlayer ? 29 : 19)
      rndx.push(rand(64))
      rndy.push(rand(64))
    end
  end
  shake = [2,2]
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...132
    for m in 0...@opposingTargets.length
      ax, ay = @userSprite.getAnchor
      cx, cy = @opposingTargets[m].getCenter(true)
      for j in 0...10
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
    #fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.5
    pbSEPlay("Anim/Bubble1",100) if i==0 || i == 40 || i == 70
    pbSEPlay("Anim/Bubble2",100) if i==10 || i == 50 || i == 80
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
  pbSEPlay("Anim/Bubble1",100)
  pbSEPlay("Anim/Bubble2",100)
  20.times do
    for m in 0...@opposingTargets.length
      @opposingTargets[m].ox += shake[m]
      shake[m] = -2 if @opposingTargets[m].ox > @opposingTargets[m].bitmap.width/2 + 2
      shake[m] = 2 if @opposingTargets[m].ox < @opposingTargets[m].bitmap.width/2 - 2
      @opposingTargets[m].still
    end
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
