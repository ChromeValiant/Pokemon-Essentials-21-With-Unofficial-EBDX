#-------------------------------------------------------------------------------
#  FLASH
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FLASH) do
  # set up animation
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(255,255,255))
  fp["bg"].opacity = 0
  @sprites["battlebg"].defocus
  @vector.set(vector)
  @scene.wait(16,true)
  # start animation
  for i in 0...62
    pbSEPlay("Anim/Flash2",100) if i == 20
    if i < 10
      fp["bg"].opacity += 25.5
    elsif i < 30
      @targetSprite.tone.all -= 18
    end
    fp["bg"].update
    @targetSprite.still
    @scene.wait
  end
  10.times do
    fp["bg"].color.alpha -= 25.5
    @targetSprite.tone.all += 25.5
    @targetSprite.still
    @scene.wait
  end
  @targetSprite.tone.all = 0
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
