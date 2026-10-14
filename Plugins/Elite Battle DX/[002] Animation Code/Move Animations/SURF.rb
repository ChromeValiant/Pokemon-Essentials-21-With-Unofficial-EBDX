#-------------------------------------------------------------------------------
#  SURF
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SURF) do
  # def ini
  vector = (@scene.battle.triplebattle?) ? EliteBattle.get_vector(:TRIPLE, @targetIsPlayer) : @scene.getRealVector(@targetIndex, @targetIsPlayer)
  factor = @userIsPlayer ? 1 : 0.75
  factorY = @userIsPlayer ? 0.992 : 1.01#1.01
  BubbleSplash = @userIsPlayer ? 15 : -15
  splash = 30
  shake = Array.new(@opposingTargets.length, 8)
  # graphic ini
  fp = {};
  fp["surf"] = Sprite.new(@viewport)
  fp["surf"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  if @userIsPlayer
	fp["surf"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb624_PU")
	fp["surf"].x = -200
	fp["surf"].y =  800
	moveX = 15
	moveY = -7
  else
	fp["surf"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb624_EU") 
	fp["surf"].x =  900
	fp["surf"].y =  -550
	moveX = -15
	moveY = 7
  end
  fp["surf"].zoom_x = factor
  fp["surf"].zoom_y = factor
  fp["surf"].ox = fp["surf"].bitmap.width/2
  fp["surf"].oy = fp["surf"].bitmap.height/2
  fp["surf"].z = @targetSprite.z + 1
  fp["surf"].opacity = 0
  # sprite ini
  @userSprite.color = Color.new(51,153,255,0)
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(vector)
  @scene.wait(4,true)
  for i in 0...75
	pbSEPlay("Anim/Water1") if i%25 == 0
    fp["surf"].opacity += 25 if fp["surf"].opacity <= 125
	fp["surf"].x += moveX
	fp["surf"].y += moveY
	fp["surf"].zoom_y = factorY * fp["surf"].zoom_y
	for m in 0...@opposingTargets.length
		if i == 35
			for v in 0...splash
				fp["p#{v}_#{m}"] = Sprite.new(@viewport)
				fp["p#{v}_#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb540_4")
				fp["p#{v}_#{m}"].center!
				fp["p#{v}_#{m}"].x, fp["p#{v}_#{m}"].y = @opposingTargets[m].getCenter(true)
				r = (40 + rand(24))*@opposingTargets[m].zoom_x
				x, y = randCircleCord(r)
				fp["p#{v}_#{m}"].end_x = fp["p#{v}_#{m}"].x - r + x
				fp["p#{v}_#{m}"].end_y = fp["p#{v}_#{m}"].y - r + y
				fp["p#{v}_#{m}"].zoom_x = 0
				fp["p#{v}_#{m}"].zoom_y = 0
				fp["p#{v}_#{m}"].angle = rand(360)
				fp["p#{v}_#{m}"].z = @opposingTargets[m].z + 1
			end
			end
		if i.between?(40,70)
		for j in 0...splash
			next if j > (i-8)*2
			fp["p#{j}_#{m}"].zoom_x += (1.6 - fp["p#{j}_#{m}"].zoom_x)*0.1
			fp["p#{j}_#{m}"].zoom_y += (1.6 - fp["p#{j}_#{m}"].zoom_y)*0.1
			fp["p#{j}_#{m}"].x += (fp["p#{j}_#{m}"].end_x - fp["p#{j}_#{m}"].x)*0.1 + BubbleSplash
			fp["p#{j}_#{m}"].y += (fp["p#{j}_#{m}"].end_y - fp["p#{j}_#{m}"].y)*0.1 - BubbleSplash
			if fp["p#{j}_#{m}"].zoom_x >= 0.5
				fp["p#{j}_#{m}"].opacity -= 16
			end
			fp["p#{j}_#{m}"].color.alpha -= 8
		end
		@opposingTargets[m].ox += shake[m]
		shake[m] = -8 if @opposingTargets[m].ox > @opposingTargets[m].bitmap.width/2 + 2
		shake[m] = 8 if @opposingTargets[m].ox < @opposingTargets[m].bitmap.width/2 - 2
		if i < 55
			@userSprite.color.alpha += 10
		else
			@userSprite.color.alpha -= 16
		end
		@userSprite.still
		@userSprite.anim = true
		end
	end
	@scene.wait(1,true)
  end
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end