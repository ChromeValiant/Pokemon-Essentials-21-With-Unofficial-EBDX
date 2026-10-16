#-------------------------------------------------------------------------------
#  POLTERGEIST
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:POLTERGEIST) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  shake = 2
  fp = {}
  fp["orb"] = TrailingSprite.new(@viewport,pbBitmap("Graphics/EBDX/Animations/Moves/eb175_3"))
  fp["orb"].keyFrame = 1
  fp["orb"].zoom_x = 1.5 if @targetIsPlayer
  fp["orb"].zoom_y = 1.5 if @targetIsPlayer
  fp["orb"].z = @targetSprite.z + 1
  @targetSprite.color = Color.new(65,66,84, 0)
  pbSEPlay("Anim/Psych Up")
  # zooming onto the target
  @vector.set(vector)
  12.times do
    @scene.wait(1,true)
  end
  # poison animation
  cxT, cyT = @targetSprite.getCenter(true)
  fp["orb"].x = cxT 
  fp["orb"].y = cyT
  fp["orb"].visible = true
  for i in 0...130

    if i <= 80
      factor = ((i*0.025).to_f - 0.5)*Math::PI
      fp["orb"].x = cxT - 55*@targetSprite.zoom_x + Math.cos(factor)*55.0*@targetSprite.zoom_x
      fp["orb"].y = cyT - 40*@targetSprite.zoom_y  + Math.sin(factor)*Math.cos(factor)*40.0*@targetSprite.zoom_y
      fp["orb"].update
      @targetSprite.anim = true
      @targetSprite.still
    elsif i <=100
      fp["orb"].y -= (i-80)
      fp["orb"].update
      @targetSprite.anim = true
      @targetSprite.still
    elsif i >= 104
      pbSEPlay("Anim/hit") if i == 107
      fp["orb"].y += (i-104) 
      fp["orb"].opacity -= 16 if fp["orb"].opacity > 0
      fp["orb"].update
      @targetSprite.color.alpha += 16
      @targetSprite.still
      @targetSprite.ox += shake
      shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
    end
    @scene.wait(1,true)
  end
  @vector.reset if !@multiHit
  8.times do
    @targetSprite.color.alpha -= 16
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
