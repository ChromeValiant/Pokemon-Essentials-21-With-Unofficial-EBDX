#-------------------------------------------------------------------------------
#  Vine Whip
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FRENZYPLANT) do
  EliteBattle.playMoveAnimation(:VINEWHIP, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, 2)
end
#-------------------------------------------------------------------------------
#  Vine Whip
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:POWERWHIP) do
  EliteBattle.playMoveAnimation(:VINEWHIP, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, 1)
end
#-------------------------------------------------------------------------------
#  Branch Poke
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:BRANCHPOKE) do
  EliteBattle.playMoveAnimation(:VINEWHIP, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, 0)
end
#-------------------------------------------------------------------------------
#  Vine Whip
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:VINEWHIP) do | args |
  type = args[0]; type = 0 if type.nil?
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  @vector.set(vector)
  @scene.wait(16,true)
  cx, cy = @targetSprite.getCenter(true)
  fp = {}
  fp["whip"] = Sprite.new(@viewport)
  fp["whip"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb208")
  fp["whip"].ox = fp["whip"].bitmap.width*0.75
  fp["whip"].oy = fp["whip"].bitmap.height*0.5
  fp["whip"].angle = 315
  fp["whip"].zoom_x = @targetSprite.zoom_x*(type > 0 ? 2 : 1.5)
  fp["whip"].zoom_y = @targetSprite.zoom_y*(type > 0 ? 2 : 1.5)
  fp["whip"].color = Color.new(255,255,255,0)
  fp["whip"].opacity = 0
  fp["whip"].x = cx + 32*@targetSprite.zoom_x
  fp["whip"].y = cy - 48*@targetSprite.zoom_y
  fp["whip"].y -= 30 if type > 0
  fp["whip"].z = @targetIsPlayer ? 29 : 19
  fp["imp"] = Sprite.new(@viewport)
  fp["imp"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb244_2")
  fp["imp"].ox = fp["imp"].bitmap.width/2
  fp["imp"].oy = fp["imp"].bitmap.height/2
  fp["imp"].zoom_x = @targetSprite.zoom_x*2
  fp["imp"].zoom_y = @targetSprite.zoom_y*2
  fp["imp"].visible = false
  fp["imp"].x = cx
  fp["imp"].y = cy - 48*@targetSprite.zoom_y
  fp["imp"].z = @targetIsPlayer ? 29 : 19
  posx = []
  posy = []
  angl = []
  zoom = []
  for j in 0...12
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb208_2")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].z = @targetIsPlayer ? 29 : 19
    fp["#{j}"].visible = false
    z = [1,1.25,0.75,0.5][rand(4)]
    fp["#{j}"].zoom_x = @targetSprite.zoom_x*z
    fp["#{j}"].zoom_y = @targetSprite.zoom_y*z
    fp["#{j}"].angle = rand(360)
    posx.push(rand(128))
    posy.push(rand(64))
    angl.push((rand(2)==0 ? 1 : -1))
    zoom.push(z)
    fp["#{j}"].opacity = (155+rand(100))
  end
  if type == 2
    fp["bg"] = ScrollingSprite.new(@viewport)
    fp["bg"].speed = 64
    fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb639_bg")
    fp["bg"].color = Color.new(0,0,0,255)
    fp["bg"].opacity = 0
    for i in 0...20
      if i < 10
        fp["bg"].opacity += 25.5
      else
        fp["bg"].color.alpha -= 25.5
      end
      fp["bg"].update
      @scene.wait(1,true)
    end
  end
  # start animation
  k = 1

  if type == 2
    dust = EBDustParticle.new(@viewport, @targetSprite, 2)
  end
  for i in 0...32

    if i == 4
      case type
      when 1
        pbSEPlay("EBDX/Anim/normal3",90)
      when 2
        pbSEPlay("Drop_Heavy",80)
      else
        pbSEPlay("EBDX/Anim/normal4",90)
      end
    end
    if i < 16
      fp["whip"].opacity += 128 if i < 4
      fp["whip"].angle += 16
      fp["whip"].color.alpha += 16 if i >= 8
      fp["whip"].zoom_x -= 0.2 if i >= 8
      fp["whip"].zoom_y -= 0.16 if i >= 4
      fp["whip"].opacity -= 64 if i >= 12
      fp["imp"].visible = true if i == 3
      if i >= 4
        fp["imp"].angle += 4
        fp["imp"].zoom_x -= 0.02
        fp["imp"].zoom_x -= 0.02
        fp["imp"].opacity -= 32
      end
      @targetSprite.zoom_y -= 0.04*k
      @targetSprite.zoom_x += 0.02*k
      @targetSprite.tone = Tone.new(255,255,255) if i == 4
      @targetSprite.tone.red -= 51 if @targetSprite.tone.red > 0
      @targetSprite.tone.green -= 51 if @targetSprite.tone.green > 0
      @targetSprite.tone.blue -= 51 if @targetSprite.tone.blue > 0
      k *= -1 if (i-4)%6==0
    end
    if type == 2
      dust.update if i < 24
      dust.dispose if i == 24
    end
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...12
      next if i < 4
      next if j>(i-4)
      fp["#{j}"].visible = true
      fp["#{j}"].x = cx - 64*@targetSprite.zoom_x*zoom[j] + posx[j]*@targetSprite.zoom_x*zoom[j]
      fp["#{j}"].y = cy - posy[j]*@targetSprite.zoom_y*zoom[j] - 48*@targetSprite.zoom_y*zoom[j]# - (i-4)*2*@targetSprite.zoom_y
      fp["#{j}"].angle += angl[j]
    end
    fp["bg"]&.update
    @scene.wait
  end
  if type == 2
    for i in 0...20
      if i < 10
        fp["bg"].color.alpha += 25.5
      else
        fp["bg"].opacity -= 25.5
      end
      fp["bg"].update
      @scene.wait
    end
  end
  @vector.reset if !@multiHit
  for i in 0...16
    @scene.wait(1,true)
    cx, cy = @targetSprite.getCenter(true)
    k = 20 - i
    for j in 0...12
      fp["#{j}"].x = cx - 64*@targetSprite.zoom_x*zoom[j] + posx[j]*@targetSprite.zoom_x*zoom[j]
      fp["#{j}"].y = cy - posy[j]*@targetSprite.zoom_y*zoom[j] - 48*@targetSprite.zoom_y*zoom[j]# - (k)*2*@targetSprite.zoom_y
      fp["#{j}"].opacity -= 16
      fp["#{j}"].angle += angl[j]
      fp["#{j}"].zoom_x = @targetSprite.zoom_x
      fp["#{j}"].zoom_y = @targetSprite.zoom_y
    end
  end
  pbDisposeSpriteHash(fp)
end
