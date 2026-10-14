#-------------------------------------------------------------------------------
#  CURSE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:CURSE) do
  if @battlers[@userIndex].pbHasType?(:GHOST)
    @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
    @scene.wait(16,true)
    factor = @userSprite.zoom_x
    cx, cy = @userSprite.getCenter(true)
    dx = []
    dy = []
    fp = {}
    mass = 40
    for j in 0...mass
      fp["#{j}"] = Sprite.new(@viewport)
      fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb59_7")
      fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
      fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
      r = 10*factor
      x, y = randCircleCord(r)
      x = cx + x
      y = cy + y
      fp["#{j}"].x = x
      fp["#{j}"].y = y
      fp["#{j}"].z = @userSprite.z
      fp["#{j}"].visible = false
      fp["#{j}"].angle = rand(360)
      z = [0.5,1,0.75][rand(3)]
      fp["#{j}"].zoom_x = z
      fp["#{j}"].zoom_y = z
      dx.push(x)
      dy.push(y)
    end
    fp["nail"] = Sprite.new(@viewport)
    fp["nail"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebCurse")
    fp["nail"].x = cx - (fp["nail"].bitmap.width/2)
    fp["nail"].y = cy - 35
    fp["nail"].zoom_x = 1.5
    fp["nail"].zoom_y = 1.5
    fp["nail"].z = @userSprite.z + 10
    # target coloring
    @userSprite.color = Color.new(130,38,137,0)
    # start animation
    for i in 0...120
      for j in 0...mass
        fp["#{j}"].visible = true
        fp["#{j}"].angle += 10
        fp["#{j}"].opacity = -32 if i > 100
      end
      fp["nail"].opacity = -32 if i > 100
      if i == 20 || i == 50 || i == 80
        fp["nail"].y += 10
        fp["nail"].src_rect.height -= 7
        pbSEPlay("EBDX/anim/Iron5",85)
      end
      if i < 20
        @userSprite.color.alpha += 10
      elsif i > 100
        @userSprite.color.alpha -= 20
      end
      @userSprite.still
      @userSprite.anim = true
      @scene.wait
    end
    @vector.reset if !@multiHit
    pbDisposeSpriteHash(fp)
  else
    EliteBattle.playMoveAnimation(:DRAGONDANCE, @scene, @userIndex, @targetIndex)
  end
end
