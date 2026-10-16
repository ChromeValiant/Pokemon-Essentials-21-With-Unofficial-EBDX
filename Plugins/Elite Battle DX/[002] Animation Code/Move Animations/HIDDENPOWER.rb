#-------------------------------------------------------------------------------
#  HIDDENPOWER
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:HIDDENPOWER) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}; rndx = []; rndy = []; dx = []; dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb263_bg_4")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for i in 0...72
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb263_4")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    rndx.push(rand(16))
    rndy.push(rand(16))
    dx.push(0)
    dy.push(0)
  end
  userReference = @battlers[@userIndex].pokemon
  #p userReference.species
  typeColor = Color.new(0,0,0,0)
  hp = pbHiddenPower(userReference)[0]
  case hp
  when :NORMAL    then typeColor = Color.new(169,168,160,230)
    when :FIGHTING  then typeColor = Color.new(209,53,86,230)
    when :FLYING    then typeColor = Color.new(178,195,226,230)
    when :FIRE      then typeColor = Color.new(246,170,68,230)
    when :WATER     then typeColor = Color.new(97,159,209,230)
    when :GRASS     then typeColor = Color.new(105,178,69,230)
    when :ELECTRIC  then typeColor = Color.new(244,220,61,230)
    when :GROUND    then typeColor = Color.new(224,125,67,230)
    when :ROCK      then typeColor = Color.new(210,194,136,230)
    when :STEEL     then typeColor = Color.new(86,150,162,230)
    when :FAIRY     then typeColor = Color.new(220,156,194,230)
    when :SOUND     then typeColor = Color.new(67,79,107,230)
    when :BUG       then typeColor = Color.new(155,185,15,230)
    when :DARK      then typeColor = Color.new(91,87,95,230)
    when :GHOST     then typeColor = Color.new(98,107,171,230)
    when :DRAGON    then typeColor = Color.new(35,100,170,230)
    when :POISON    then typeColor = Color.new(171,99,162,230)
    when :PSYCHIC   then typeColor = Color.new(239,131,128,230)
    when :ICE       then typeColor = Color.new(136,202,187,230)
  end
  for i in 0...72
    fp["#{i}2"] = Sprite.new(@viewport)
    fp["#{i}2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb263_3_blank")
    fp["#{i}2"].ox = fp["#{i}2"].bitmap.width/2
    fp["#{i}2"].oy = fp["#{i}2"].bitmap.height/2
    fp["#{i}2"].color = typeColor
    fp["#{i}2"].opacity = 0
    fp["#{i}2"].z = 19
  end
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb263")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = 50
  fp["cir"].zoom_x = @targetIsPlayer ? 0.5 : 1
  fp["cir"].zoom_y = @targetIsPlayer ? 0.5 : 1
  fp["cir"].opacity = 0
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb263_2")
    fp["#{i}s"].ox = -32 - rand(64)
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height/2
    fp["#{i}s"].angle = rand(270)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(vector2)
  for i in 0...20
    if i < 10
      fp["bg"].opacity += 25.5
    else
      fp["bg"].color.alpha -= 25.5
    end
    pbSEPlay("Anim/Harden") if i == 4
    fp["bg"].update
    @scene.wait(1,true)
  end
  @scene.wait(4,true)
  pbSEPlay("Anim/Psych Up")
  for i in 0...96
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...72
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        dx[j] = ax - 8*@userSprite.zoom_x*0.5 + rndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 8*@userSprite.zoom_y*0.5 + rndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])

      fp["#{j}2"].color = typeColor
      next if j>(i)
      if i>32 && i < 60
        dx[j] = ax - 8*@userSprite.zoom_x*0.5 + rndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 8*@userSprite.zoom_y*0.5 + rndy[j]*@userSprite.zoom_y*0.5
      end
      x0 = dx[j]
      y0 = dy[j]
      x2 = cx - 8*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 8*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].opacity += 51
      fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].z = @targetSprite.z - 1 if nextx > cx && nexty < cy
      else
        fp["#{j}"].z = @targetSprite.z + 1 if nextx < cx && nexty > cy
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
      fp["#{j}2"].color = typeColor
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    pbSEPlay("Anim/Comet Punch") if i == 64
    fp["cir"].x, fp["cir"].y = ax, ay
    fp["cir"].angle += 32
    fp["cir"].opacity += (i>72) ? -51 : 255
    fp["bg"].update
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].zoom_x += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].zoom_y += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = ax, ay
    end
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  fp["cir"].opacity = 0
  for i in 0...20
    @targetSprite.still
    if i < 10
      fp["bg"].color.alpha += 25.5
    else
      fp["bg"].opacity -= 25.5
    end
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
