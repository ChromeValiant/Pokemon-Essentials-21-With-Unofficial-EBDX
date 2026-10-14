#-------------------------------------------------------------------------------
#  SYRUP BOMB
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SYRUPBOMB) do | args |
  bomb = args[0]; bomb = true if bomb.nil?
  fp = {}
  fp["sludge"] = TrailingSprite.new(@viewport,pbBitmap("Graphics/EBDX/Animations/Moves/eb429_red"))
  fp["sludge"].keyFrame = 1
  fp["sludge"].z = @targetSprite.z + 1
  # shooting out the sludge
  for i in 0...24
    cxT, cyT = @targetSprite.getCenter(true)
    cxP, cyP = @userSprite.getAnchor(true)
    mx = @vector.x + (@vector.x2 - @vector.x)*0.5
    points = calculateCurve(cxP,cyP,mx,-32,cxT,cyT,24)
    fp["sludge"].x = points[i][0]
    fp["sludge"].y = points[i][1]
    z = 1 + (1-(fp["sludge"].x - @vector.x).to_f/(@vector.x2 - @vector.x))
    fp["sludge"].zoom_x = z
    fp["sludge"].zoom_y = z
    fp["sludge"].update
    @scene.wait(1,true)
  end
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @targetSprite.color = Color.new(235, 64, 52,0)
  fp["sludge"].dispose
  # zooming onto the target
  8.times do
    @targetSprite.color.alpha += 18
    @targetSprite.anim = true
    @targetSprite.still
    @scene.wait(1,true)
  end
  # rest of the particles
  for j in 0...32
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb429_2")
    fp["p#{j}"].center!
    fp["p#{j}"].x, fp["p#{j}"].y = @targetSprite.getCenter(true)
    r = (40 + rand(24))*@targetSprite.zoom_x
    x, y = randCircleCord(r)
    fp["p#{j}"].end_x = fp["p#{j}"].x - r + x
    fp["p#{j}"].end_y = fp["p#{j}"].y - r + y
    fp["p#{j}"].zoom_x = 0
    fp["p#{j}"].zoom_y = 0
    fp["p#{j}"].angle = rand(360)
    fp["p#{j}"].z = @targetSprite.z + 1
    fp["p#{j}"].color = Color.new(235, 64, 52)
  end
  # poison animation
  for i in 0...64
    break if !bomb && i > 15
    for j in 0...32
      next if !bomb
      next if i < 8
      next if j > (i-8)*2
      fp["p#{j}"].zoom_x += (1.6 - fp["p#{j}"].zoom_x)*0.1
      fp["p#{j}"].zoom_y += (1.6 - fp["p#{j}"].zoom_y)*0.1
      fp["p#{j}"].x += (fp["p#{j}"].end_x - fp["p#{j}"].x)*0.1
      fp["p#{j}"].y += (fp["p#{j}"].end_y - fp["p#{j}"].y)*0.1
      if fp["p#{j}"].zoom_x >= 1
        fp["p#{j}"].opacity -= 16
      end
      fp["p#{j}"].color.alpha -= 8
    end
    @targetSprite.color.alpha -= 16 if i >= 48
    @targetSprite.anim = true
    @targetSprite.still
    @scene.wait(1,i < 8)
  end
  pbDisposeSpriteHash(fp)
  @vector.reset
end
