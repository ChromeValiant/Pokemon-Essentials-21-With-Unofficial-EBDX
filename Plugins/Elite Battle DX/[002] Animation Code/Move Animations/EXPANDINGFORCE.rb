#-------------------------------------------------------------------------------
#  Expanding Force
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:EXPANDINGFORCE) do | args |
  strike = *args; strike = false if strike.nil?
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  q = 0
  shake = 2
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(150,55,137,255))
  fp["bg"].opacity = 0
  y_start = (@targetIsPlayer ? 350 : 300)
  for i in 0...8
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebExpandingForce")
    fp["#{i}"].src_rect.set(0,0,98,430)
    fp["#{i}"].y = y_start + 1
    fp["#{i}"].opacity = 0
    fp["#{i}"].ox = fp["#{i}"].src_rect.width/2
    fp["#{i}"].zoom_x = 0.5
    fp["#{i}"].z = 50
  end
  bolt_height = fp["0"].bitmap.height
  fp["circle"] = Sprite.new(@viewport)
  fp["circle"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb064")
  fp["circle"].ox = fp["circle"].bitmap.width/2
  fp["circle"].oy = fp["circle"].bitmap.height/2
  fp["circle"].opacity = 0
  fp["circle"].zoom_x = 0.5
  fp["circle"].zoom_y = 0.5
  fp["circle"].color = Color.new(150,55,137,255)
  fp["circle"].z = @targetSprite.z + 2
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(vector)
  pbSEPlay("Anim/Refresh")
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  cx, cy = @targetSprite.getCenter(true)
  fp["circle"].x = cx
  fp["circle"].y = cy + 80
  @targetSprite.color = Color.new(150,55,137,0)
  for i in 0...96
    for j in 0...8
      next if j>(i/4)
      if fp["#{j}"].y >= 301 && i < 32
        pbSEPlay("Anim/Psych up",80) if i%8==0
        fp["#{j}"].x = cx - 32*@targetSprite.zoom_x + rand(64)*@targetSprite.zoom_x
        fp["#{j}"].src_rect.x = 98*rand(3)
        t = rand(5)*48
        fp["#{j}"].opacity = 255
        fp["#{j}"].tone = Tone.new(t,t,t)
        fp["#{j}"].mirror = (rand(2)==0 ? true : false)
      end
      fp["#{j}"].src_rect.x += 98
      fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= 294
      fp["#{j}"].y -= (@targetIsPlayer ? @vector.y : @vector.y2)/8.0 if fp["#{j}"].opacity > 0
      fp["#{j}"].opacity -= 16 if fp["#{j}"].y <= (@targetIsPlayer ? @vector.y : @vector.y2) - 32
      if fp["#{j}"].y < y_start && fp["#{j}"].y + bolt_height >= y_start
        fp["#{j}"].src_rect.height = [bolt_height,y_start - fp["#{j}"].y].min
      end
      fp["#{j}"].y = 0 if fp["#{j}"].opacity <= 0
    end
    fp["circle"].zoom_x += 0.1
    fp["circle"].zoom_y += 0.06
    fp["circle"].opacity += (i>=24 ? -40 : 40)
    fp["bg"].opacity -= 32 if i >= 90

    @targetSprite.color.alpha += 16 if i >= 40 && @targetSprite.color.alpha < 120
    @targetSprite.anim = true
    @targetSprite.still if i >= 32
    @scene.wait(1,true)
  end
  pbSEPlay("Anim/psychic1")
  8.times do
    @targetSprite.ox += shake
    shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
    shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
    @targetSprite.color.alpha -= 16
    @targetSprite.anim = true
    @targetSprite.still
    @scene.wait(1,true)
  end
  @scene.wait(8,true)
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
