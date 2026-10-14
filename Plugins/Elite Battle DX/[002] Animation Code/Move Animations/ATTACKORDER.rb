#-------------------------------------------------------------------------------
#  HEALORDER
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:HEALORDER) do
  EliteBattle.playMoveAnimation(:ATTACKORDER, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, "heal")
end
#-------------------------------------------------------------------------------
#  DEFENSEORDER
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:DEFENSEORDER) do
  EliteBattle.playMoveAnimation(:ATTACKORDER, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, "defense")
end
#-------------------------------------------------------------------------------
#  ATTACKORDER
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ATTACKORDER) do |args|
  #-----------------------------------------------------------------------------
  #  configure variables
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16, true)
  type = args[0]; type = "attack" if type.nil?
  fp = {}; k = -1; bees = 8 ; shake = 2
  factor = @targetSprite.zoom_x
  reversed = []; cx, cy = @targetSprite.getCenter(true)
  #-----------------------------------------------------------------------------
  #  set up sprites
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(166,223,160))
  fp["bg"].opacity = 0
  for j in 0...12
    fp["particle#{j}"] = Sprite.new(@viewport)
    if type == "attack"
      fp["particle#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb008")
      fp["particle#{j}"].src_rect.set(32*rand(2),0,32,32)
    elsif type == "defense"
      fp["particle#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb303_2_3")
    else
      fp["particle#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb619_4")
    end
    fp["particle#{j}"].ox = fp["particle#{j}"].src_rect.width/2
    fp["particle#{j}"].oy = fp["particle#{j}"].src_rect.height/2
    r = 32*factor
    fp["particle#{j}"].x = cx - r + rand(r*2)
    fp["particle#{j}"].y = cy - r + rand(r*2)
    fp["particle#{j}"].z = @targetSprite.z + 1
    fp["particle#{j}"].visible = false
  end
  for j in 0...bees
    fp["bees#{j}"] = Sprite.new(@viewport)
    fp["bees#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebBees")
    fp["bees#{j}"].src_rect.set(53*rand(4),0,53,101)
    fp["bees#{j}"].ox = 26
    fp["bees#{j}"].oy = 101
    fp["bees#{j}"].zoom_x = factor
    fp["bees#{j}"].zoom_y = factor
    fp["bees#{j}"].opacity = 0
    fp["bees#{j}"].y = cy - 48*factor - k*2*factor
    fp["bees#{j}"].x = cx + 64*factor - (j%4)*32*factor
    reversed.push([false,true][j/4])
  end
  #-----------------------------------------------------------------------------
  #  play animation
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  vol = 80
  for i in 0...70
    k = i*0.5 if i < 64
    if type == "attack"
      pbSEPlay("EBDX/Anim/bug1",100) if i%4==0 && i >= 40
    elsif type == "defense"
      pbSEPlay("EBDX/Anim/iron5",100) if i == 40 && i == 50
    else
      pbSEPlay("Anim/Absorb2",100) if i == 40
      pbSEPlay("Anim/Saint8",70) if i == 40
    end
    vol -= 5 if i%8 == 0
    for j in 0...bees
      reversed[j] = true if fp["bees#{j}"].x <= cx - 64*factor
      reversed[j] = false if fp["bees#{j}"].x >= cx + 64*factor
      fp["bees#{j}"].z = reversed[j] ? @targetSprite.z - 1 : @targetSprite.z + 1
      fp["bees#{j}"].mirror = reversed[j]
      fp["bees#{j}"].y = cy - 48*factor - k*1.5*factor - (reversed[j] ? 4*factor : 0) + 120 if !@targetIsPlayer
      fp["bees#{j}"].y = cy - 48*factor - k*1.5*factor - (reversed[j] ? 4*factor : 0) + 200 if @targetIsPlayer
      fp["bees#{j}"].x -= reversed[j] ? -4*factor : 4*factor
	    next if j>(i/4)
      fp["bees#{j}"].opacity += 16 if fp["bees#{j}"].opacity < 150
      fp["bees#{j}"].opacity -= 25 if i >= 48
	    fp["bees#{j}"].src_rect.x += 53 if j%4==0
      fp["bees#{j}"].src_rect.x = 0 if fp["bees#{j}"].src_rect.x >= fp["bees#{j}"].bitmap.width
    end
    if i >= 30
      @targetSprite.ox += shake
      shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
      for h in 0...12
        next if h>(i/4)
        fp["particle#{h}"].visible = true
        fp["particle#{h}"].opacity -= 32
        fp["particle#{h}"].zoom_x += 0.02
        fp["particle#{h}"].zoom_y += 0.02
        fp["particle#{h}"].angle += 8
      end
	  end
    @scene.wait(1,true)
  end
  20.times do
    if type == "attack"
      @targetSprite.ox += shake
      shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    fp["bg"].opacity -= 15
    @scene.wait(1,true)
  end
  #-----------------------------------------------------------------------------
  #  dispose sprites
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
  #-----------------------------------------------------------------------------
end
