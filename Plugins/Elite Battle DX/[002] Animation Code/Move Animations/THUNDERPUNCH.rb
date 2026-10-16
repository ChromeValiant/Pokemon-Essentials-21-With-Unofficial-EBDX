#-------------------------------------------------------------------------------
#  Thunderous Kick
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:THUNDEROUSKICK) do
  EliteBattle.playMoveAnimation(:THUNDERPUNCH, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
#-------------------------------------------------------------------------------
#  Supercell Slam
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SUPERCELLSLAM) do
  EliteBattle.playMoveAnimation(:THUNDERPUNCH, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
#-------------------------------------------------------------------------------
#  Hawkwire Kick
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:HAYWIREKICK) do
  EliteBattle.playMoveAnimation(:THUNDERPUNCH, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
#-------------------------------------------------------------------------------
#  Thunder Punch
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:THUNDERPUNCH) do |args|
  factor = (@targetIsPlayer ? 2 : 1.5)
  kick = args[0]; kick = false if kick.nil?
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(217/6,189/6,52/6))
  fp["bg"].opacity = 0
  l = 0; m = 0; q = 0
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb064_2")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 51
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
  fp["hit"].color = Color.new(217,189,52,50)
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  pbSEPlay("Anim/fog2",75)
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
      fp["hit"].tone.all-=25.5
      fp["hit"].opacity -= 25.5
    end
    pbSEPlay("Anim/hit") if i==40
    pbSEPlay("Anim/Thunder3") if i==40
    pbSEPlay("Anim/Paralyze1") if i%8==0 && i>=52
    for n in 0...12
      next if i < 40
      if fp["#{n}"].opacity == 0 && fp["#{n}"].tone.gray == 0
        r2 = rand(4)
        fp["#{n}"].zoom_x = [0.2,0.25,0.5,0.75][r2]
        fp["#{n}"].zoom_y = [0.2,0.25,0.5,0.75][r2]
        fp["#{n}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
        x, y = randCircleCord(48*factor)
        fp["#{n}"].x = cx - 48*factor*@targetSprite.zoom_x + x*@targetSprite.zoom_x
        fp["#{n}"].y = cy - 48*factor*@targetSprite.zoom_y + y*@targetSprite.zoom_y
        fp["#{n}"].angle = -Math.atan(1.0*(fp["#{n}"].y-cy)/(fp["#{n}"].x-cx))*(180.0/Math::PI) + rand(2)*180 + rand(90)
      end
      next if m>(i-40)/4
      fp["#{n}"].opacity += 51 if fp["#{n}"].tone.gray == 0
      fp["#{n}"].angle += 180 if (i-16)%3==0
      fp["#{n}"].tone.gray = 1 if fp["#{n}"].opacity >= 255
      q += 1 if fp["#{n}"].opacity >= 255
      fp["#{n}"].opacity -= 10 if fp["#{n}"].tone.gray > 0 && q > 96
    end
    fp["bg"].opacity += 4 if  i < 40
    fp["bg"].opacity -= 10 if i >= 56
    @targetSprite.tone = Tone.new(100,80,60) if i == 40
    if i >= 40
      if (i-40)/3 > l
        m += 1
        m = 0 if m > 1
        l = (i-40)/3
      end
      @targetSprite.zoom_y -= 0.16*(m==0 ? 1 : -1)
      @targetSprite.zoom_x += 0.08*(m==0 ? 1 : -1)
      @targetSprite.tone.red -= 5 if @targetSprite.tone.red > 0
      @targetSprite.tone.green -= 4 if @targetSprite.tone.green > 0
      @targetSprite.tone.blue -= 3 if @targetSprite.tone.blue > 0
      @targetSprite.still
    end
    @scene.wait(1,(i < 40))
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
#-------------------------------------------------------------------------------
#  Thunderstrikes
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:THUNDERSTRIKES) do |args|
  factor = (@targetIsPlayer ? 2 : 1.5)
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(217/6,189/6,52/6))
  fp["bg"].opacity = 0
  l = 0; m = 0; q = 0
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb064_2")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 51
  end
  for i in 0...4
    fp["thunder#{i}"] = Sprite.new(@viewport)
    fp["thunder#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb069_2")
    fp["thunder#{i}"].src_rect.set(0,0,98,430)
    fp["thunder#{i}"].ox = fp["thunder#{i}"].src_rect.width/2
    fp["thunder#{i}"].oy = fp["thunder#{i}"].src_rect.height
    fp["thunder#{i}"].zoom_x = 0.5
    fp["thunder#{i}"].z = 50
  end

  fp["hit"] = Sprite.new(@viewport)
  fp["hit"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb303")
  fp["hit"].src_rect.set(0,0,64,64)
  fp["hit"].ox = 32
  fp["hit"].oy = 32
  fp["hit"].opacity = 0
  fp["hit"].z = 40
  fp["hit"].color = Color.new(217,189,52,50)
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  pbSEPlay("Anim/fog2",75)
  for i in 0...72
    cx, cy = @targetSprite.getCenter(true)
    fp["hit"].x = cx
    fp["hit"].y = cy
    fp["hit"].opacity = 255 if i == 35
    fp["hit"].src_rect.x = 64 if i == 40
    if i >= 40
      fp["hit"].tone = Tone.new(255,255,255) if i == 40
      fp["hit"].tone.all-=25.5
      fp["hit"].opacity -= 8
      for j in 0...4
        if fp["thunder#{j}"].y <= 0 && i == 40
          fp["thunder#{j}"].x = cx - 32*@targetSprite.zoom_x + rand(64)*@targetSprite.zoom_x
          fp["thunder#{j}"].src_rect.x = 98*rand(3)
          t = rand(5)*48
          fp["thunder#{j}"].opacity = 255
          fp["thunder#{j}"].tone = Tone.new(t,t,t)
          fp["thunder#{j}"].mirror = (rand(2)==0 ? true : false)
        end
        fp["thunder#{j}"].src_rect.x += 98
        fp["thunder#{j}"].src_rect.x = 0 if fp["thunder#{j}"].src_rect.x >= 294
        fp["thunder#{j}"].y += (@targetIsPlayer ? @vector.y : @vector.y2)/8.0 if fp["thunder#{j}"].y < (@targetIsPlayer ? @vector.y : @vector.y2) + 32
        fp["thunder#{j}"].opacity -= 32 if fp["thunder#{j}"].y >= (@targetIsPlayer ? @vector.y : @vector.y2) + 32
        fp["thunder#{j}"].y = 0 if fp["thunder#{j}"].opacity <= 0
      end
    end
    pbSEPlay("Anim/hit") if i==40
    pbSEPlay("Anim/Thunder3") if i==40
    pbSEPlay("Anim/Paralyze1") if i%8==0 && i>=52
    for n in 0...12
      next if i < 40
      if fp["#{n}"].opacity == 0 && fp["#{n}"].tone.gray == 0
        r2 = rand(4)
        fp["#{n}"].zoom_x = [0.2,0.25,0.5,0.75][r2]
        fp["#{n}"].zoom_y = [0.2,0.25,0.5,0.75][r2]
        fp["#{n}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
        x, y = randCircleCord(48*factor)
        fp["#{n}"].x = cx - 48*factor*@targetSprite.zoom_x + x*@targetSprite.zoom_x
        fp["#{n}"].y = cy - 48*factor*@targetSprite.zoom_y + y*@targetSprite.zoom_y
        fp["#{n}"].angle = -Math.atan(1.0*(fp["#{n}"].y-cy)/(fp["#{n}"].x-cx))*(180.0/Math::PI) + rand(2)*180 + rand(90)
      end
      next if m>(i-40)/4
      fp["#{n}"].opacity += 51 if fp["#{n}"].tone.gray == 0
      fp["#{n}"].angle += 180 if (i-16)%3==0
      fp["#{n}"].tone.gray = 1 if fp["#{n}"].opacity >= 255
      q += 1 if fp["#{n}"].opacity >= 255
      fp["#{n}"].opacity -= 10 if fp["#{n}"].tone.gray > 0 && q > 96
    end
    fp["bg"].opacity += 4 if  i < 40
    fp["bg"].opacity -= 10 if i >= 56
    @targetSprite.tone = Tone.new(100,80,60) if i == 40
    if i >= 40
      if (i-40)/3 > l
        m += 1
        m = 0 if m > 1
        l = (i-40)/3
      end
      @targetSprite.zoom_y -= 0.16*(m==0 ? 1 : -1)
      @targetSprite.zoom_x += 0.08*(m==0 ? 1 : -1)
      @targetSprite.tone.red -= 5 if @targetSprite.tone.red > 0
      @targetSprite.tone.green -= 4 if @targetSprite.tone.green > 0
      @targetSprite.tone.blue -= 3 if @targetSprite.tone.blue > 0
      @targetSprite.still
    end
    @scene.wait(1,(i < 40))
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
