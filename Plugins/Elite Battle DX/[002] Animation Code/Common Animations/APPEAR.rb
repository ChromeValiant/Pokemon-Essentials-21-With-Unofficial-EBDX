#===============================================================================
#  Common Animation: APPEAR
#===============================================================================
EliteBattle.defineCommonAnimation(:APPEAR) do
  #-----------------------------------------------------------------------------
  # clear UI elements
  #  hides UI elements
  isVisible = []
  @battlers.each_with_index do |b, i|
    isVisible.push(false)
    next if !b
    isVisible[i] = @sprites["dataBox_#{i}"].visible
    @sprites["dataBox_#{i}"].visible = false
  end
  @scene.clearMessageWindow
  #-----------------------------------------------------------------------------
  fp = {}
  pokemon = @battlers[@targetIndex]
  #-----------------------------------------------------------------------------
  back = @targetIndex%2 == 0
  @vector.set(@scene.getRealVector(@targetIndex, back))
  @scene.wait(16, true)
  @targetSprite.opacity = 0
  #-----------------------------------------------------------------------------
  # finish up animation
  @targetSprite.tone = Tone.new(-255, -255, -255)
  @sprites["battlebg"].focus
  fp["impact"] = Sprite.new(@viewport)
  fp["impact"].bitmap = pbBitmap("Graphics/EBDX/Pictures/impact")
  fp["impact"].center!(true)
  fp["impact"].z = 999
  fp["impact"].opacity = 0
  @targetDatabox.refresh
  k = -2
  for i in 0...40  
    @targetSprite.opacity += 16 if @targetSprite.opacity < 255
    @scene.wait(1, false)
  end
  playBattlerCry(@battlers[@targetIndex])
  for i in 0...24
    fp["impact"].opacity += 64
    fp["impact"].angle += 180 if i%4 == 0
    fp["impact"].mirror = !fp["impact"].mirror if i%4 == 2
    k *= -1 if i%4 == 0
    @targetSprite.tone.all += 16
    @targetSprite.tone.all = 0 if @targetSprite.tone.all >= 0
    @scene.moveEntireScene(0, k, true, true)
    @scene.wait(1, false)
  end
  for i in 0...16
    fp["impact"].opacity -= 64
    fp["impact"].angle += 180 if i%4 == 0
    fp["impact"].mirror = !fp["impact"].mirror if i%4 == 2
    @scene.wait
  end
  #-----------------------------------------------------------------------------
  #  return to original and dispose particles
  @battlers.each_with_index do |b, i|
    next if !b
    @sprites["dataBox_#{i}"].visible = true if isVisible[i]
  end
  fp["impact"].dispose
  @vector.reset
  @scene.wait(16, true)
  #-----------------------------------------------------------------------------
end
