#-------------------------------------------------------------------------------
#  Aerial ace
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:AERIALACE) do
  factor = @targetSprite.zoom_x
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(8,true)
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  j = 0
  # set up animation
  fp = {}
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb263_bg_4")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0

  fp["claw"] = Sprite.new(@viewport)
  fp["claw"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb602_4")
  fp["claw"].ox = fp["claw"].bitmap.width/2
  fp["claw"].oy = fp["claw"].bitmap.height/2
  fp["claw"].x = cx
  fp["claw"].y = cy
  fp["claw"].zoom_x = factor
  fp["claw"].zoom_y = factor
  fp["claw"].color = Color.new(3, 194, 252)
  fp["claw"].src_rect.height = 0
  fp["claw"].z = @targetSprite.z + 1
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...20
    if i < 10
      fp["bg"].opacity += 25.5
    else
      fp["bg"].color.alpha -= 25.5
    end
    fp["bg"].update
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/ground1",75)
  @scene.wait(1,true)
  for i in 1..11
    # if i < 8
      # x=(i/4 < 1) ? 2 : -2
      # @scene.moveEntireScene(0, x*2, true, true)
    # end
    if i.between?(1,5)
      @targetSprite.still
      @targetSprite.zoom_y-=0.05*factor
      @targetSprite.tone.all-=12.8
    end
  	if j == 0 && i == 6
  	  for k in 0...32
  		pbSEPlay("EBDX/Anim/normal3",85) if k == 4
  		fp["claw"].src_rect.height += 20
  		fp["claw"].opacity -= 32 if k >= 16
  		@scene.wait(1,true)
  	  end
  	  j = 1
  	end
    if i.between?(7,11)
      @targetSprite.still
      @targetSprite.zoom_y+=0.05*factor
      @targetSprite.tone.all+=12.8
    end
    fp["bg"].update
  end
  @vector.reset if !@multiHit
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
  pbDisposeSpriteHash(fp)
end
#-------------------------------------------------------------------------------
