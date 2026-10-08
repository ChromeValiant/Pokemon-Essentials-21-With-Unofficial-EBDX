#===============================================================================
#  Primega shattering-orb engine for Mega Evolution and Primal Reversion
#  Usage: PrimegaShatter.define(:ANIMATIONID, { :texture, :overlay, :bg, :bg_hue, :symbol, :sym_z })
#===============================================================================
module PrimegaShatter
  FOLDER = "Graphics/EBDX/Animations/Moves/Primega/"
  MOVES  = "Graphics/EBDX/Animations/Moves/"
  COUNT  = 26
  STEP   = 3
  @cache = {}
  def self.piece(n, texture, overlay)
    key = "#{texture}|#{overlay}|#{n}"
    c = @cache[key]
    return nil if c == :empty
    return c if c && c[0] && !c[0].disposed? && (!c[5] || !c[5].disposed?)
    mask = pbBitmap(sprintf("%scr%03d", FOLDER, n))
    om   = pbBitmap(FOLDER + texture)
    ov   = (overlay ? (pbBitmap(FOLDER + overlay) rescue nil) : nil)
    w, h = mask.width, mask.height
    ccx, ccy = w / 2.0, h / 2.0
    rad = [w, h].min / 2.0
    lim = (rad + 1.5) * (rad + 1.5)
    inside = lambda { |px, py| (px - ccx) ** 2 + (py - ccy) ** 2 <= lim }
    cov = lambda do |px|
      px.alpha * [px.red, px.green, px.blue].max / 255.0
    end
    minx, miny, maxx, maxy = w, h, -1, -1
    y = 0
    while y < h
      x = 0
      while x < w
        if inside.call(x, y) && cov.call(mask.get_pixel(x, y)) > 0
          minx = x if x < minx
          maxx = x if x > maxx
          miny = y if y < miny
          maxy = y if y > maxy
        end
        x += STEP
      end
      y += STEP
    end
    if maxx < 0
      @cache[key] = :empty
      return nil
    end
    minx = [minx - STEP, 0].max
    miny = [miny - STEP, 0].max
    maxx = [maxx + STEP, w - 1].min
    maxy = [maxy + STEP, h - 1].min
    bw = maxx - minx + 1
    bh = maxy - miny + 1
    bmp  = Bitmap.new(bw, bh)
    cbmp = ov ? Bitmap.new(bw, bh) : nil
    sx = om.width.to_f / w
    sy = om.height.to_f / h
    vsx = ov ? ov.width.to_f / w : 1.0
    vsy = ov ? ov.height.to_f / h : 1.0
    drawn = false
    for yy in miny..maxy
      for xx in minx..maxx
        next if !inside.call(xx, yy)
        m = cov.call(mask.get_pixel(xx, yy))
        next if m <= 0
        edge = rad - Math.sqrt((xx - ccx) ** 2 + (yy - ccy) ** 2) + 0.5
        next if edge <= 0
        m *= edge if edge < 1
        if cbmp
          vc = ov.get_pixel([(xx * vsx).to_i, ov.width - 1].min, [(yy * vsy).to_i, ov.height - 1].min)
          if vc.alpha > 0
            cbmp.set_pixel(xx - minx, yy - miny, Color.new(vc.red, vc.green, vc.blue, vc.alpha * m / 255.0))
          end
        end
        ox = [(xx * sx).to_i, om.width - 1].min
        oy = [(yy * sy).to_i, om.height - 1].min
        oc = om.get_pixel(ox, oy)
        a  = oc.alpha * m / 255.0
        next if a <= 0
        bmp.set_pixel(xx - minx, yy - miny, Color.new(oc.red, oc.green, oc.blue, a))
        drawn = true
      end
    end
    if !drawn
      bmp.dispose
      cbmp.dispose if cbmp
      @cache[key] = :empty
      return nil
    end
    @cache[key] = [bmp, minx + bw / 2.0, miny + bh / 2.0, w, h, cbmp]
    return @cache[key]
  end
  def self.background(cfg)
    if cfg[:bg] && pbResolveBitmap(MOVES + cfg[:bg])
      return pbBitmap(MOVES + cfg[:bg])
    end
    base = pbBitmap(MOVES + "ebMegaBg")
    hue = cfg[:bg_hue].to_i % 360
    return base if hue == 0
    bmp = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    bmp.hue_change(hue)
    return bmp
  end
  def self.define(id, cfg)
    EliteBattle.defineCommonAnimation(id) do
      isVisible = []
      @battlers.each_with_index do |b, i|
        isVisible.push(false)
        next if !b
        isVisible[i] = @sprites["dataBox_#{i}"].visible
        @sprites["dataBox_#{i}"].visible = false
      end
      @scene.clearMessageWindow
      fp = {}
      sh = {}
      pokemon = @battlers[@targetIndex]
      back = @targetIndex%2 == 0
      begin
        @vector.set(@scene.getRealVector(@targetIndex, back))
        @scene.wait(16, true)
        factor = @targetSprite.zoom_x
        fp["bg"] = ScrollingSprite.new(@viewport)
        fp["bg"].setBitmap(PrimegaShatter.background(cfg))
        fp["bg"].speed = 32
        fp["bg"].opacity = 0
        for i in 0...16
          fp["c#{i}"] = Sprite.new(@viewport)
          fp["c#{i}"].z = @targetSprite.z + 10
          fp["c#{i}"].bitmap = pbBitmap(sprintf("Graphics/EBDX/Animations/Moves/ebMega%03d", rand(4)+1))
          fp["c#{i}"].center!
          fp["c#{i}"].opacity = 0
        end
        rangle = []
        cx, cy = @targetSprite.getCenter(true)
        for i in 0...8; rangle.push((360/8)*i +  15); end
        for j in 0...8
          fp["r#{j}"] = Sprite.new(@viewport)
          fp["r#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebMega005")
          fp["r#{j}"].ox = 0
          fp["r#{j}"].oy = fp["r#{j}"].bitmap.height/2
          fp["r#{j}"].opacity = 0
          fp["r#{j}"].zoom_x = 0
          fp["r#{j}"].zoom_y = 0
          fp["r#{j}"].x = cx
          fp["r#{j}"].y = cy
          a = rand(rangle.length)
          fp["r#{j}"].angle = rangle[a]
          fp["r#{j}"].z = @targetSprite.z + 2
          rangle.delete_at(a)
        end
        for j in 0...3
          fp["v#{j}"] = Sprite.new(@viewport)
          fp["v#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebMega006")
          fp["v#{j}"].center!
          fp["v#{j}"].x = cx
          fp["v#{j}"].y = cy
          fp["v#{j}"].opacity = 0
          fp["v#{j}"].zoom_x = 2
          fp["v#{j}"].zoom_y = 2
        end
        fp["circle"] = Sprite.new(@viewport)
        fp["circle"].bitmap = Bitmap.new(@targetSprite.bitmap.width*1.25,@targetSprite.bitmap.height*1.25)
        fp["circle"].bitmap.bmp_circle
        fp["circle"].center!
        fp["circle"].x = cx
        fp["circle"].y = cy
        fp["circle"].z = @targetSprite.z + 10
        fp["circle"].zoom_x = 0
        fp["circle"].zoom_y = 0
        circle_d = fp["circle"].bitmap.width * factor
        shards = []
        make_shard = lambda do |n|
          data = PrimegaShatter.piece(n, cfg[:texture], cfg[:overlay])
          next if !data
          bmp, pcx, pcy, mw, mh, cbmp = data
          sc = circle_d / [mw, mh].min.to_f
          spr = Sprite.new(@viewport)
          spr.bitmap = bmp
          spr.ox = bmp.width / 2
          spr.oy = bmp.height / 2
          spr.zoom_x = sc
          spr.zoom_y = sc
          spr.x = cx + (pcx - mw / 2.0) * sc
          spr.y = cy + (pcy - mh / 2.0) * sc
          spr.z = @targetSprite.z + 11
          spr.opacity = 0
          sh["s#{n}"] = spr
          crk = nil
          if cbmp
            crk = Sprite.new(@viewport)
            crk.bitmap = cbmp
            crk.ox = cbmp.width / 2
            crk.oy = cbmp.height / 2
            crk.zoom_x = sc
            crk.zoom_y = sc
            crk.x = spr.x
            crk.y = spr.y
            crk.z = @targetSprite.z + 12
            crk.opacity = 0
            crk.blend_type = 1
            sh["k#{n}"] = crk
          end
          dd = Math.sqrt((spr.x - cx) ** 2 + (spr.y - cy) ** 2)
          t0 = 84 + ((dd / (circle_d / 2.0)) * 32).to_i
          shards.push({ :sprite => spr, :crack => crk, :x => spr.x, :y => spr.y, :sc => sc, :t0 => t0,
                        :vx => 0.0, :vy => 0.0, :vr => 0.0, :vz => 0.0, :flash => 0 })
        end
        sync_crack = lambda do |s|
          c = s[:crack]
          next if !c
          sp = s[:sprite]
          c.x = sp.x
          c.y = sp.y
          c.angle = sp.angle
          c.zoom_x = sp.zoom_x
          c.zoom_y = sp.zoom_y
        end
        z = 0.02
        @sprites["battlebg"].defocus
        pbSEPlay("Anim/Harden",120)
        for i in 0...128
          fp["bg"].opacity += 8
          fp["bg"].update
          @targetSprite.tone.all += 8 if @targetSprite.tone.all < 255
          for j in 0...16
            next if j > (i/8)
            if fp["c#{j}"].opacity == 0 && i < 72
              fp["c#{j}"].opacity = 255
              x, y = randCircleCord(96*factor)
              fp["c#{j}"].x = cx - 96*factor + x
              fp["c#{j}"].y = cy - 96*factor + y
            end
            x2 = cx
            y2 = cy
            x0 = fp["c#{j}"].x
            y0 = fp["c#{j}"].y
            fp["c#{j}"].x += (x2 - x0)*0.1
            fp["c#{j}"].y += (y2 - y0)*0.1
            fp["c#{j}"].opacity -= 16
          end
          for j in 0...8
            if fp["r#{j}"].opacity == 0 && j <= (i%128)/16 && i < 96
              fp["r#{j}"].opacity = 255
              fp["r#{j}"].zoom_x = 0
              fp["r#{j}"].zoom_y = 0
            end
            fp["r#{j}"].opacity -= 4
            fp["r#{j}"].zoom_x += 0.05
            fp["r#{j}"].zoom_y += 0.05
          end
          if i < 48
          elsif i < 64
            fp["circle"].zoom_x += factor/16.0
            fp["circle"].zoom_y += factor/16.0
          else
            z *= -1 if (i-96)%4 == 0
            fp["circle"].zoom_x += z
            fp["circle"].zoom_y += z
          end
          make_shard.call(i + 1) if i < PrimegaShatter::COUNT
          pbSEPlay("Anim/Harden", 100) if i == 90
          for s in shards
            next if i < s[:t0]
            age = i - s[:t0]
            spr = s[:sprite]
            spr.opacity = [age * 64 + 40, 255].min
            pz = age < 6 ? 1.0 + (6 - age) * 0.05 : 1.0
            spr.zoom_x = s[:sc] * pz
            spr.zoom_y = s[:sc] * pz
          end
          pbSEPlay("Anim/Twine", 80) if i == 40
          pbSEPlay("Anim/Refresh") if i == 56
          if i >= 24
            for j in 0...3
              next if j > (i-32)/8
              next if fp["v#{j}"].zoom_x <= 0
              fp["v#{j}"].opacity += 16
              fp["v#{j}"].zoom_x -= 0.05
              fp["v#{j}"].zoom_y -= 0.05
            end
          end
          @scene.wait(1,true)
        end
        pbSEPlay("Anim/Rock Smash", 55)
        for i in 0...24
          fp["bg"].update
          amp = 0.4 + i / 7.0
          base = i * 5
          for s in shards
            s[:sprite].x = s[:x] + (rand * 2 - 1) * amp
            s[:sprite].y = s[:y] + (rand * 2 - 1) * amp
            sync_crack.call(s)
            s[:crack].opacity = [i * 14 + 30, 255].min if s[:crack]
            s[:flash] = 255 if rand(100) < 6 + i
            s[:flash] = [s[:flash] - 45, 0].max
            f = [[s[:flash], base].max, 255].min
            s[:sprite].tone = Tone.new(f, f, f, 0)
          end
          fp["circle"].zoom_x += factor * 0.006
          fp["circle"].zoom_y += factor * 0.006
          pbSEPlay("Anim/Refresh", 70) if i == 14
          @scene.wait(1, true)
        end
        @scene.wait(4, true)
        @viewport.color = Color.white
        pbSEPlay("Vs flash", 80)
        pbSEPlay("Anim/Rock Smash", 100)
        pbDisposeSpriteHash(fp)
        @sprites["battlebg"].focus
        @targetSprite.tone.all = 255
        for s in shards
          dx = s[:x] - cx
          dy = s[:y] - cy
          dist = Math.sqrt(dx*dx + dy*dy)
          if dist < 1
            ang = rand * Math::PI * 2
            dx, dy, dist = Math.cos(ang), Math.sin(ang), 1.0
          end
          speed = 5.0 + rand * 6.0
          s[:vx] = dx / dist * speed
          s[:vy] = dy / dist * speed - 1.0 - rand * 2.0
          s[:vr] = (rand * 16.0) - 8.0
          s[:vz] = rand * 0.03
          s[:flash] = 255
          s[:sprite].tone = Tone.new(255, 255, 255, 0)
        end
        update_shards = lambda do |fade, ts|
          for s in shards
            s[:vx] *= 0.95
            s[:vy] *= 0.95
            s[:vy] += 0.4 * ts
            s[:x]  += s[:vx] * ts
            s[:y]  += s[:vy] * ts
            spr = s[:sprite]
            spr.x = s[:x]
            spr.y = s[:y]
            spr.angle += s[:vr] * ts
            spr.zoom_x += s[:vz] * s[:sc] * ts
            spr.zoom_y += s[:vz] * s[:sc] * ts
            if s[:flash] > 0
              s[:flash] = [s[:flash] - 20, 0].max
              spr.tone = Tone.new(s[:flash], s[:flash], s[:flash], 0)
            end
            spr.opacity -= 12 if fade
            sync_crack.call(s)
            s[:crack].opacity = spr.opacity if s[:crack]
          end
        end
        for j in 0...2
          fp["ring#{j}"] = Sprite.new(@viewport)
          fp["ring#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebMega006")
          fp["ring#{j}"].center!
          fp["ring#{j}"].x = cx
          fp["ring#{j}"].y = cy
          fp["ring#{j}"].z = 997
          fp["ring#{j}"].zoom_x = 0.2
          fp["ring#{j}"].zoom_y = 0.2
          fp["ring#{j}"].opacity = 0
        end
        for j in 0...10
          fp["ray#{j}"] = Sprite.new(@viewport)
          fp["ray#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebMega005")
          fp["ray#{j}"].ox = 0
          fp["ray#{j}"].oy = fp["ray#{j}"].bitmap.height / 2
          fp["ray#{j}"].x = cx
          fp["ray#{j}"].y = cy
          fp["ray#{j}"].z = 996
          fp["ray#{j}"].angle = j * 36 + rand(20)
          fp["ray#{j}"].zoom_x = 0.2
          fp["ray#{j}"].zoom_y = 0.5 + rand * 0.5
          fp["ray#{j}"].opacity = 255
          fp["ray#{j}"].blend_type = 1
        end
        sparks = []
        for j in 0...14
          fp["p#{j}"] = Sprite.new(@viewport)
          fp["p#{j}"].bitmap = pbBitmap(sprintf("Graphics/EBDX/Animations/Moves/ebMega%03d", rand(4)+1))
          fp["p#{j}"].center!
          fp["p#{j}"].x = cx
          fp["p#{j}"].y = cy
          fp["p#{j}"].z = 997
          fp["p#{j}"].zoom_x = 0.6 + rand * 0.6
          fp["p#{j}"].zoom_y = fp["p#{j}"].zoom_x
          ang = rand * Math::PI * 2
          spd = 6.0 + rand * 8.0
          sparks.push([Math.cos(ang) * spd, Math.sin(ang) * spd])
        end
        fp["impact"] = Sprite.new(@viewport)
        fp["impact"].bitmap = pbBitmap("Graphics/EBDX/Pictures/impact")
        fp["impact"].center!(true)
        fp["impact"].z = 999
        fp["impact"].opacity = 0
        @targetSprite.setPokemonBitmap(pokemon, back)
        @targetSprite.tone.all = 255
        @targetDatabox.refresh
        playBattlerCry(@battlers[@targetIndex])
        cx, cy = @targetSprite.getCenter(true)
        fp["sym"] = Sprite.new(@viewport)
        fp["sym"].bitmap = pbBitmap(PrimegaShatter::MOVES + cfg[:symbol])
        fp["sym"].center!(true)
        fp["sym"].x = cx
        fp["sym"].y = cy
        fp["sym"].z = cfg[:sym_z] || 1000
        fp["sym"].zoom_x = 2.5
        fp["sym"].zoom_y = 2.5
        fp["sym"].opacity = 0
        k = -2
        for i in 0...24
          fp["impact"].opacity += 64
          fp["impact"].angle += 180 if i%4 == 0
          fp["impact"].mirror = !fp["impact"].mirror if i%4 == 2
          fp["sym"].opacity += 24
          if fp["sym"].zoom_x > 1.0
            fp["sym"].zoom_x -= 0.15
            fp["sym"].zoom_y -= 0.15
          end
          @targetSprite.tone.all = [@targetSprite.tone.all - 13, 0].max if i > 1
          for j in 0...2
            next if i < j * 5
            fp["ring#{j}"].opacity = 255 if i == j * 5
            fp["ring#{j}"].zoom_x += 0.28
            fp["ring#{j}"].zoom_y += 0.28
            fp["ring#{j}"].opacity -= 12
          end
          for j in 0...10
            fp["ray#{j}"].zoom_x += 0.3
            fp["ray#{j}"].opacity -= 14
          end
          for j in 0...14
            fp["p#{j}"].x += sparks[j][0]
            fp["p#{j}"].y += sparks[j][1]
            sparks[j][0] *= 0.94
            sparks[j][1] *= 0.94
            fp["p#{j}"].opacity -= 10 if i > 4
          end
          update_shards.call(i >= 14, [0.25 + i * 0.1, 1.0].min)
          k *= -1 if i%4 == 0
          @viewport.color.alpha -= 16 if i > 1
          @scene.moveEntireScene(0, k, true, true)
          @scene.wait(1, false)
        end
        @targetSprite.tone.all = 0
        for i in 0...16
          fp["impact"].opacity -= 64
          fp["impact"].angle += 180 if i%4 == 0
          fp["impact"].mirror = !fp["impact"].mirror if i%4 == 2
          update_shards.call(true, 1.0)
          @scene.wait
        end
        for i in 0...16
          fp["sym"].opacity -= 16
          fp["sym"].zoom_x += 0.05
          fp["sym"].zoom_y += 0.05
          update_shards.call(true, 1.0)
          @scene.wait(1, true)
        end
      rescue => err
        begin
          @sprites["battlebg"].focus
          @viewport.color = Color.new(0, 0, 0, 0)
          @targetSprite.tone.all = 0
          @targetSprite.setPokemonBitmap(pokemon, back)
          @targetDatabox.refresh
        rescue
        end
        raise err
      ensure
        @battlers.each_with_index do |b, i|
          next if !b
          @sprites["dataBox_#{i}"].visible = true if isVisible[i]
        end
        pbDisposeSpriteHash(fp)
        pbDisposeSpriteHash(sh)
        @vector.reset
      end
      @scene.wait(16, true)
    end
  end

  def self.flush
    queue = $primega_queue || []
    $primega_queue = []
    queue.each { |id, cfg| define(id, cfg) }
  end
end

PrimegaShatter.flush
