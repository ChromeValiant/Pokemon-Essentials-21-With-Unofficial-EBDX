#-------------------------------------------------------------------------------
#  STRENGTHSAP
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:STRENGTHSAP) do
  # configure animation
  @vector.set(@scene.getRealVector(@userIndex, @targetIsPlayer))
  @scene.wait(16,true)
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  dx = []
  dy = []
  fp = {}
  t = 32
  cxT, cyT = @targetSprite.getCenter(true)
  cxP, cyP = @userSprite.getCenter(true)
  mx = !@targetIsPlayer ? (cxT-cxP)/2 : (cxP-cxT)/2
  mx += @targetIsPlayer ? cxT : cxP
  my = !@targetIsPlayer ? (cyP-cyT)/2 : (cyT-cyP)/2
  my += @targetIsPlayer ? cyP : cyT
  curves = []
  zoom = []
  #
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(245, 204, 255))
  fp["bg"].opacity = 0
  #
  for j in 0...t
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb619")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    r = 64*factor
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    fp["#{j}"].x = cx
    fp["#{j}"].y = cx
    fp["#{j}"].z = @targetSprite.z
    fp["#{j}"].visible = false
    fp["#{j}"].angle = rand(360)
    z = [0.5,1,0.75][rand(3)]
    fp["#{j}"].zoom_x = z
    fp["#{j}"].zoom_y = z
    v = 1
    ox = -16*factor + rand(32*factor) - 32*v + rand(64*v)
    oy = -16*factor + rand(32*factor) - 32*v + rand(64*v)
    vert = rand(96)*(rand(2)==0 ? 1 : -1)*(factor**2)
    curve = calculateCurve(cxT+ox,cyT+oy,mx,my+vert+oy,cxP+ox,cyP+oy,32)
    curves.push(curve)
    zoom.push(z)
    dx.push(x)
    dy.push(y)
  end
  # start animation
  #
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  #
  pbSEPlay("Anim/Wish",80)
  for i in 0...2*t
    for j in 0...t
      next if j>(i*2)
      fp["#{j}"].visible = true
      if ((fp["#{j}"].x - dx[j])*0.1).abs < 1
        #fp["#{j}"].opacity -= 32
      else
        fp["#{j}"].x -= (fp["#{j}"].x - dx[j])*0.1
        fp["#{j}"].y -= (fp["#{j}"].y - dy[j])*0.1
      end
    end
    @scene.wait
  end
  @sprites["battlebg"].defocus
  #@vector.reset
  #@scene.wait(16,true)
  for i in 0...64
    for j in 0...t
      next if j> i / (32/t)
      k = i - j*(32/t)
      fp["#{j}"].visible = false if k >= t
      k = t - 1 if k >= t
      k = 0 if k < 0
      fp["#{j}"].x = curves[j][k][0]
      fp["#{j}"].y = curves[j][k][1]
      fp["#{j}"].opacity += (k < 16) ? 64 : -16
      fp["#{j}"].zoom_x -= (fp["#{j}"].zoom_x - @targetSprite.zoom_x*zoom[j])*0.1
      fp["#{j}"].zoom_y -= (fp["#{j}"].zoom_y - @targetSprite.zoom_y*zoom[j])*0.1
    end
    pbSEPlay("Anim/Recovery",80) if  i == (t/2)
    @scene.wait(1,true)
  end
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
