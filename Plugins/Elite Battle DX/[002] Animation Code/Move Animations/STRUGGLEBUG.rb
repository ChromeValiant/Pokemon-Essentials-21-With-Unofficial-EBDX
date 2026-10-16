#-------------------------------------------------------------------------------
#  Struggle Bug
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:STRUGGLEBUG) do
  # configure animation
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  @scene.wait(16,true)
  factor = @userSprite.zoom_x
  cx, cy = @userSprite.getCenter(true)
  dx = []
  dy = []
  fp = {}

  for m in 0...@opposingTargets.length
    for j in 0...24
      fp["#{m}_#{j}"] = Sprite.new(@viewport)
      fp["#{m}_#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb010")
      fp["#{m}_#{j}"].ox = fp["#{m}_#{j}"].bitmap.width/2
      fp["#{m}_#{j}"].oy = fp["#{m}_#{j}"].bitmap.height/2
      r = 64*factor
      x, y = randCircleCord(r)
      x = cx - r + x
      y = cy - r + y
      fp["#{m}_#{j}"].x = cx
      fp["#{m}_#{j}"].y = cx
      fp["#{m}_#{j}"].z = @userSprite.z
      fp["#{m}_#{j}"].visible = false
      fp["#{m}_#{j}"].angle = rand(360)
      z = [0.5,1,0.75][rand(3)]
      fp["#{m}_#{j}"].zoom_x = z
      fp["#{m}_#{j}"].zoom_y = z
      dx.push(x)
      dy.push(y)
    end
  end
  # start animation
  pbSEPlay("EBDX/Anim/ground1",80)
  for i in 0...48
    for m in 0...@opposingTargets.length
      for j in 0...24
        next if j>(i*2)
        fp["#{m}_#{j}"].visible = true
        if ((fp["#{m}_#{j}"].x - dx[j])*0.1).abs < 1
          fp["#{m}_#{j}"].opacity -= 32
        else
          fp["#{m}_#{j}"].x -= (fp["#{m}_#{j}"].x - dx[j])*0.1
          fp["#{m}_#{j}"].y -= (fp["#{m}_#{j}"].y - dy[j])*0.1
        end
      end
    end
    @scene.wait
  end
  vector = (@scene.battle.triplebattle?) ? EliteBattle.get_vector(:TRIPLE, @targetIsPlayer) : @scene.getRealVector(@targetIndex, @targetIsPlayer)
  @vector.set(vector)
  @scene.wait(16,true)
  for m in 0...@opposingTargets.length
    factor = @opposingTargets[m].zoom_x
    cx, cy = @opposingTargets[m].getCenter(true)
    for j in 0...12
      fp["s#{m}_#{j}"] = Sprite.new(@viewport)
      fp["s#{m}_#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb244_2")
      fp["s#{m}_#{j}"].ox = fp["s#{m}_#{j}"].bitmap.width/2
      fp["s#{m}_#{j}"].oy = fp["s#{m}_#{j}"].bitmap.height/2
      r = 32*factor
      fp["s#{m}_#{j}"].x = cx - r + rand(r*2)
      fp["s#{m}_#{j}"].y = cy - r + rand(r*2)
      fp["s#{m}_#{j}"].z = @opposingTargets[m].z + 1
      fp["s#{m}_#{j}"].visible = false
      fp["s#{m}_#{j}"].tone = Tone.new(255,255,255)
      fp["s#{m}_#{j}"].angle = rand(360)
    end
  end
  # anim2
  for i in 0...32
    for m in 0...@opposingTargets.length
      for j in 0...12
        next if j>(i*2)
        fp["s#{m}_#{j}"].visible = true
        fp["s#{m}_#{j}"].opacity -= 32
        fp["s#{m}_#{j}"].zoom_x += 0.02
        fp["s#{m}_#{j}"].zoom_y += 0.02
        fp["s#{m}_#{j}"].angle += 8
        fp["s#{m}_#{j}"].tone.red -= 32
        fp["s#{m}_#{j}"].tone.green -= 32
        fp["s#{m}_#{j}"].tone.blue -= 32
      end
      @opposingTargets[m].still
    end
    pbSEPlay("EBDX/Anim/normal2",80) if i%4==0 && i < 16
    @scene.wait
  end
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
