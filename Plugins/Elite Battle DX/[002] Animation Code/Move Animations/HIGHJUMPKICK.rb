#-------------------------------------------------------------------------------
#  JUMPKICK
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:JUMPKICK) do
  EliteBattle.playMoveAnimation(:HIGHJUMPKICK, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
#-------------------------------------------------------------------------------
#  ROLLINGKICK
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ROLLINGKICK) do
  EliteBattle.playMoveAnimation(:HIGHJUMPKICK, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
#-------------------------------------------------------------------------------
#  AXEKICK
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:MEGAKICK) do
  EliteBattle.playMoveAnimation(:HIGHJUMPKICK, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end

#-------------------------------------------------------------------------------
#  AXEKICK
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:AXEKICK) do
  EliteBattle.playMoveAnimation(:HIGHJUMPKICK, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end

#-------------------------------------------------------------------------------
#  HIGHJUMPKICK
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:HIGHJUMPKICK) do
  factor = @targetSprite.zoom_x
  x1Move = @userIsPlayer ? 3 : -3
  x2Move = @userIsPlayer ? 13 : -13
  shake  = 10
  idx =  0 # counter
  dir = -1 # direction
  userOX = @userSprite.ox
  # set up animation
  start = {}
  start["bg"] = Sprite.new(@viewport)
  start["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  start["bg"].bitmap.fill_rect(0,0,start["bg"].bitmap.width,start["bg"].bitmap.height,Color.black)
  start["bg"].opacity = 0
  # phase 1
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  16.times do
    start["bg"].opacity += 12
    @scene.wait(1,true)
  end
  # user move
  for i in 0...50
    @userSprite.still
	@userSprite.ox += shake if i == 19
	pbSEPlay("Anim/TakeDownCharge",100) if i == 20 || i == 40
	pbSEPlay("Anim/TakeDownAttack",100) if i == 40
	#default movement
  if i.between?(0,20)
		@userSprite.ox += x1Move
	end
	if i.between?(20,40)
		@userSprite.still
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
	if i.between?(40,50)
		@userSprite.ox -= x2Move
    end
    @scene.wait(1,true)
  end

  # phase 2
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  for i in 0...8
	@userSprite.ox += x2Move/2
    @scene.wait(1,true)
  end
  @scene.wait(5,true)



  factor = @targetSprite.zoom_x
  fp = {}; rndx = []; rndy = []
  pbSEPlay("EBDX/Anim/ground1",80)
  for i in 0...2
    4.times do
      @userSprite.x += 8*(@targetIsPlayer ? -1 : 1)*(i==0 ? 1 : -1)
      @userSprite.x -= 2*(@targetIsPlayer ? -1 : 1)*(i==0 ? 1 : -1)
      @scene.wait
    end
  end

  @scene.wait(16,true)
  for i in 0...16
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb008_2")
    fp["#{i}"].ox = 6
    fp["#{i}"].oy = 6
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    r = rand(3)
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)*(r==0 ? 1 : 0.5)
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)*(r==0 ? 1 : 0.5)
    fp["#{i}"].tone = Tone.new(60,60,60)
    rndx.push(rand(128))
    rndy.push(rand(128))
  end

  factor = 1
  frame = Sprite.new(@viewport)
  frame.z = 50
  frame.bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb520_2")
  frame.src_rect.set(0,0,114,114)
  frame.ox = 57
  frame.oy = 57
  frame.zoom_x = 0.5*factor
  frame.zoom_y = 0.5*factor
  frame.x, frame.y = @targetSprite.getCenter(true)
  frame.opacity = 0
  frame.tone = Tone.new(255,255,255)
  fp["hit"] = Sprite.new(@viewport)
  fp["hit"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb137")
  fp["hit"].ox = fp["hit"].bitmap.width/2
  fp["hit"].oy = fp["hit"].bitmap.height/2
  fp["hit"].x, fp["hit"].y = @targetSprite.getCenter(true)
  fp["hit"].opacity = 0
  fp["hit"].z = 40
  fp["hit"].zoom_x = @targetIsPlayer ? 4 : 2
  fp["hit"].zoom_y = @targetIsPlayer ? 4 : 2
  fp["hit"].color = Color.new(217,189,52,50)
  # start animation
  for i in 1..30
    if i == 6
      pbSEPlay("Anim/hit",80)
    end
    if i.between?(1,5)
      @targetSprite.still
      @targetSprite.zoom_y-=0.05*factor
      @targetSprite.tone.all-=12.8
      frame.zoom_x += 0.1*factor
      frame.zoom_y += 0.1*factor
      frame.opacity += 51
    end
    frame.tone = Tone.new(0,0,0) if i == 6
    if i.between?(6,10)
      @targetSprite.still
      @targetSprite.zoom_y+=0.05*factor
      @targetSprite.tone.all+=12.8
      fp["hit"].zoom_x += 0.2*factor
      fp["hit"].zoom_y += 0.2*factor
      fp["hit"].opacity += 51
      frame.angle += 2
    end
    frame.src_rect.x = 114 if i == 10
    if i >= 10
      frame.opacity -= 25.5
      frame.zoom_x += 0.1*factor
      frame.zoom_y += 0.1*factor
      frame.angle += 2
      fp["hit"].zoom_x += 0.2*factor
      fp["hit"].zoom_y += 0.2*factor
      fp["hit"].opacity -= 25.5
    end
    for j in 0...16
      next if i < 6
      cx = frame.x; cy = frame.y
      if fp["#{j}"].opacity == 0 && fp["#{j}"].visible
        fp["#{j}"].x = cx
        fp["#{j}"].y = cy
      end
      x2 = cx - 64*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 64*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.2
      fp["#{j}"].y += (y2 - y0)*0.2
      fp["#{j}"].zoom_x += 0.01
      fp["#{j}"].zoom_y += 0.01
      fp["#{j}"].angle += 2
      if i < 20
        fp["#{j}"].tone.red -= 6; fp["#{j}"].tone.blue -= 6; fp["#{j}"].tone.green -= 6
      end
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["#{j}"].opacity -= 51
      else
        fp["#{j}"].opacity += 51
      end
      fp["#{j}"].visible = false if fp["#{j}"].opacity <= 0
    end
    @scene.wait
  end


  16.times do
    start["bg"].opacity -= 20
    @scene.wait(1,true)
  end

  @userSprite.ox = userOX
  frame.dispose
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end
