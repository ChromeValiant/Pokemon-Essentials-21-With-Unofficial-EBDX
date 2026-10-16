
#-------------------------------------------------------------------------------
#  SILKTRAP
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SILKTRAP) do
  # set up animation
  fp = {}; rndx = []; rndy = []; dx = []; dy = []; px = []; py = []; rangl = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(229,255,204))
  fp["bg"].opacity = 0
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  cxT, cyT = @targetSprite.getCenter(true)
  fp["net"] = Sprite.new(@viewport)
	fp["net"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb621")
	fp["net"].center!
	fp["net"].x = cxT
	fp["net"].y = cyT
	fp["net"].zoom_x = 0
	fp["net"].zoom_y = 0
	fp["net"].angle = rand(360)
	fp["net"].z = @targetSprite.z + 30
	for i in 0...30
		pbSEPlay("Anim/Splat",90) if i == 5
		next if i < 1
		fp["net"].zoom_x += (1.6 - fp["net"].zoom_x)*0.1
		fp["net"].zoom_y += (1.6 - fp["net"].zoom_y)*0.1
		if fp["net"].zoom_x >= 1
		  fp["net"].opacity -= 16
		end
	    fp["net"].color.alpha -= 8
		@scene.wait(1,i < 1)
	end
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
