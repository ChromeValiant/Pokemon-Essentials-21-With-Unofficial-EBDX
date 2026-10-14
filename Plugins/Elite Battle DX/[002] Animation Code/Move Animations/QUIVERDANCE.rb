#-------------------------------------------------------------------------------
#  ACUPRESSURE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:VICTORYDANCE) do | args |
  EliteBattle.playMoveAnimation(:QUIVERDANCE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  TEETERDANCE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:TEETERDANCE) do | args |
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  fp = {}
  r1 = 50
  r2 = 12
  #
  speed = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  #
  for j in 0...32
    fp["particle_#{j}"] = Sprite.new(@viewport)
    fp["particle_#{j}"].z = @userIsPlayer ? 29 : 19
    fp["particle_#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebConfused")
    fp["particle_#{j}"].src_rect.set(0,101*rand(3),53,101)
    fp["particle_#{j}"].ox = 26
    fp["particle_#{j}"].oy = 101
    fp["particle_#{j}"].color = Color.new(255,255,255,255)
    fp["particle_#{j}"].opacity = 0
    speed.push((rand(8)+1)*2)
  end
  # set up animation
  @scene.wait(16,true)
  #
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  
  cx, cy = @userSprite.getCenter(true)
  ex, ey = @userSprite.ox, @userSprite.oy
  for i in 0..72
	  pbSEPlay("Anim/confusion1") if i == 12 || i == 42
    @userSprite.still
    #default movement
    if i > 3
      factor = i * Math::PI*10 / 180.0;
      @userSprite.ox = ex + r1 * Math.cos(factor)
      @userSprite.oy = ey + r2 * Math.sin(factor)
    else
      @userSprite.ox += 5
    end
    for j in 0...32
      next if i < 8
      next if j>(i-8)
	    fp["particle_#{j}"].src_rect.x += 53 if i%4==0
      fp["particle_#{j}"].src_rect.x = 0 if fp["particle_#{j}"].src_rect.x >= fp["particle_#{j}"].bitmap.width
      if fp["particle_#{j}"].opacity == 0 && fp["particle_#{j}"].color.alpha == 255
        fp["particle_#{j}"].y = @userSprite.y + 6*@userSprite.zoom_y - rand(24)*@userSprite.zoom_y
        fp["particle_#{j}"].x = cx - 64*@userSprite.zoom_x + rand(128)*@userSprite.zoom_x
      end
      if fp["particle_#{j}"].color.alpha <= 96
        fp["particle_#{j}"].opacity -= 54
      else
        fp["particle_#{j}"].opacity += 54
      end
      fp["particle_#{j}"].color.alpha -= 16
      fp["particle_#{j}"].y -= speed[j]
    end
    @userSprite.still
    @userSprite.anim = true
    @scene.wait(1,true)
  end
  @userSprite.ox = ex
  @userSprite.oy = ey
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
#-------------------------------------------------------------------------------
#  DOUBLETEAM
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:QUIVERDANCE) do
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  fp = {}
  r1 = 50
  r2 = 12
  #
  speed = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  #
  for j in 0...32
    fp["particle_#{j}"] = Sprite.new(@viewport)
    fp["particle_#{j}"].z = @userIsPlayer ? 29 : 19
    fp["particle_#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb057_4")
    fp["particle_#{j}"].src_rect.set(0,101*rand(3),53,101)
    fp["particle_#{j}"].ox = 26
    fp["particle_#{j}"].oy = 101
    fp["particle_#{j}"].color = Color.new(255,255,255,255)
    z = [0.5,0.75,0.8,0.75,0.6][rand(5)]
    fp["particle_#{j}"].zoom_x = z
    fp["particle_#{j}"].zoom_y = z
    fp["particle_#{j}"].opacity = 0
    speed.push((rand(8)+1)*2)
  end
  for j in 0...8
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].z = @userIsPlayer ? 29 : 19
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb057_1")
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height
    #z = [0.5,1.5,1,0.75,1.25][rand(5)]
    fp["s#{j}"].color = Color.new(255,255,255,255)
    #fp["s#{j}"].zoom_y = z
    fp["s#{j}"].opacity = 0
  end

  # set up animation
  @scene.wait(16,true)
  #
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  
  cx, cy = @userSprite.getCenter(true)
  ex, ey = @userSprite.ox, @userSprite.oy
  for i in 0..72
    pbSEPlay("Anim/Saint6",150) if i == 12
    @userSprite.still
    #default movement
    if i > 3
      factor = i * Math::PI*10 / 180.0;
      @userSprite.ox = ex + r1 * Math.cos(factor)
      @userSprite.oy = ey + r2 * Math.sin(factor)
    else
      @userSprite.ox += 5
    end
    for j in 0...32
      next if i < 8
      next if j>(i-8)
	    fp["particle_#{j}"].src_rect.x += 53 if i%4==0
      fp["particle_#{j}"].src_rect.x = 0 if fp["particle_#{j}"].src_rect.x >= fp["particle_#{j}"].bitmap.width
      if fp["particle_#{j}"].opacity == 0 && fp["particle_#{j}"].color.alpha == 255
        fp["particle_#{j}"].y = @userSprite.y + 6*@userSprite.zoom_y - rand(24)*@userSprite.zoom_y
        fp["particle_#{j}"].x = cx - 64*@userSprite.zoom_x + rand(128)*@userSprite.zoom_x
      end
      if fp["particle_#{j}"].color.alpha <= 96
        fp["particle_#{j}"].opacity -= 54
      else
        fp["particle_#{j}"].opacity += 54
      end
      fp["particle_#{j}"].color.alpha -= 16
      fp["particle_#{j}"].y -= speed[j]
    end
    for j in 0...8
      next if i < 12
      next if j>(i-12)/2
      if fp["s#{j}"].opacity == 0 && fp["s#{j}"].color.alpha == 255
        fp["s#{j}"].y = @userSprite.y + 48*@userSprite.zoom_y - rand(16)*@userSprite.zoom_y
        fp["s#{j}"].x = cx - 64*@userSprite.zoom_x + rand(128)*@userSprite.zoom_x
      end
      if fp["s#{j}"].color.alpha <= 96
        fp["s#{j}"].opacity -= 32
      else
        fp["s#{j}"].opacity += 32
      end
      fp["s#{j}"].color.alpha -= 16
      fp["s#{j}"].zoom_y += speed[j]*0.25*0.01
      fp["s#{j}"].y -= speed[j]
    end
    @userSprite.still
    @userSprite.anim = true
    @scene.wait(1,true)
  end
  @userSprite.ox = ex
  @userSprite.oy = ey
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
