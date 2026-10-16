#-------------------------------------------------------------------------------
#  DRAGONDARTS
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:DRAGONDARTS) do | args |
    vector = (@scene.battle.triplebattle?) ? EliteBattle.get_vector(:TRIPLE, @targetIsPlayer) : @scene.getRealVector(@targetIndex, @targetIsPlayer)
    factorHorn = @userIsPlayer ? 1.9 : 2.5
    hornXMove = @userIsPlayer ? 2 : -2
    hornYMove = @userIsPlayer ? 10 : -10
    hornXOffset = @userIsPlayer ? 180 : -280
    hornYOffset = @userIsPlayer ? 120 : -240
    hornMoveHit = @userIsPlayer ? 60 : -60
    hornAngle = @userIsPlayer ? 0 : 180
    userOX = @userSprite.ox
    # set up animation
    fp = {}
    rndx = Array.new(@opposingTargets.length, []); rndy = Array.new(@opposingTargets.length, [])
    fp["bg"] = Sprite.new(@viewport)
    fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.blue)
    fp["bg"].opacity = 0
    for m in 0...@opposingTargets.length
        for i in 0...12
            fp["#{m}_#{i}"] = Sprite.new(@viewport)
            fp["#{m}_#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb303_2_6")
            fp["#{m}_#{i}"].ox = 10
            fp["#{m}_#{i}"].oy = 10
            fp["#{m}_#{i}"].opacity = 0
            fp["#{m}_#{i}"].z = 50
            r = rand(3)
            fp["#{m}_#{i}"].zoom_x = (@opposingTargets[m].zoom_x)*(r==0 ? 1 : 0.5)
            fp["#{m}_#{i}"].zoom_y = (@opposingTargets[m].zoom_y)*(r==0 ? 1 : 0.5)
            fp["#{m}_#{i}"].tone = Tone.new(60,60,60)
            rndx[m].push(rand(128))
            rndy[m].push(rand(64))
        end
    end
    # phase 1
    if @hitNum == 0 #&& @multiHit
        @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer)) 
        16.times do
        fp["bg"].opacity += 12
        @scene.wait(1,true)
        end
        # user move
        for i in 0...30
        @userSprite.still
        #default movement
        if i.between?(0,20)
            @userSprite.ox += hornXMove
        else
            @userSprite.ox -= hornYMove
        end
        @scene.wait(1,true)
        end
    end
    # phase 2
    @vector.set(vector)
    @scene.wait(12,true)
    pbSEPlay("EBDX/Anim/normal1",80)
    for m in 0...@opposingTargets.length
        factor = @opposingTargets[m].zoom_y
        fp["impact_#{m}"] = Sprite.new(@viewport)
        fp["impact_#{m}"].z = 50
        fp["impact_#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb303")
        fp["impact_#{m}"].src_rect.set(0,0,64,64)
        fp["impact_#{m}"].ox = 32
        fp["impact_#{m}"].oy = 32
        fp["impact_#{m}"].zoom_x = 0.5*factor
        fp["impact_#{m}"].zoom_y = 0.5*factor
        fp["impact_#{m}"].x, fp["impact_#{m}"].y = @opposingTargets[m].getCenter(true)
        fp["impact_#{m}"].opacity = 0
        fp["impact_#{m}"].color = Color.new(40,41,122, 170)
        fp["impact_#{m}"].tone = Tone.new(255,255,255)
        fp["impact_#{m}"].y -= 32*@opposingTargets[m].zoom_y
        fp["horn_#{m}"] = Sprite.new(@viewport)
        fp["horn_#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb626_dart")
        fp["horn_#{m}"].ox = fp["horn_#{m}"].bitmap.width/2
        fp["horn_#{m}"].oy = fp["horn_#{m}"].bitmap.height/2
        fp["horn_#{m}"].x, fp["horn_#{m}"].y = @opposingTargets[m].getCenter(true)
        fp["horn_#{m}"].x -= hornXOffset
        fp["horn_#{m}"].y += hornYOffset
        fp["horn_#{m}"].opacity = 100
        fp["horn_#{m}"].zoom = factorHorn
        fp["horn_#{m}"].angle = hornAngle
        fp["horn_#{m}"].z = 41
    end
    # horn attack
    for i in 1..30
        for m in 0...@opposingTargets.length
            factor = @opposingTargets[m].zoom_y
            if i.between?(1,15)
                fp["horn_#{m}"].opacity += 20
                fp["horn_#{m}"].x += hornMoveHit 
                fp["horn_#{m}"].y -= hornMoveHit
            else
                fp["horn_#{m}"].opacity -= 20
            end
            if i.between?(1,5)
                @opposingTargets[m].still
                @opposingTargets[m].zoom_y-=0.05*factor
                @opposingTargets[m].tone.all-=12.8
                fp["impact_#{m}"].zoom_x += 0.1*factor
                fp["impact_#{m}"].zoom_y += 0.1*factor
                fp["impact_#{m}"].opacity += 51
            end
            fp["impact_#{m}"].tone = Tone.new(0,0,0) if i == 6
            if i.between?(6,10)
                @opposingTargets[m].still
                @opposingTargets[m].zoom_y+=0.05*factor
                @opposingTargets[m].tone.all+=12.8
                fp["impact_#{m}"].angle += 2
            end
            fp["impact_#{m}"].src_rect.x = 64 if i == 10
            if i >= 10
                fp["impact_#{m}"].opacity -= 25.5
                fp["impact_#{m}"].zoom_x += 0.1*factor
                fp["impact_#{m}"].zoom_y += 0.1*factor
                fp["impact_#{m}"].angle += 2
            end
            for j in 0...12
                cx = fp["impact_#{m}"].x; cy = fp["impact_#{m}"].y
                if fp["#{m}_#{j}"].opacity == 0 && fp["#{m}_#{j}"].visible
                fp["#{m}_#{j}"].x = cx
                fp["#{m}_#{j}"].y = cy
                end
                x2 = cx - 64*@opposingTargets[m].zoom_x + rndx[m][j]*@opposingTargets[m].zoom_x
                y2 = cy - 64*@opposingTargets[m].zoom_y + rndy[m][j]*@opposingTargets[m].zoom_y
                x0 = fp["#{m}_#{j}"].x
                y0 = fp["#{m}_#{j}"].y
                fp["#{m}_#{j}"].x += (x2 - x0)*0.2
                fp["#{m}_#{j}"].y += (y2 - y0)*0.2
                fp["#{m}_#{j}"].zoom_x += 0.01
                fp["#{m}_#{j}"].zoom_y += 0.01
                if i < 20
                fp["#{m}_#{j}"].tone.red -= 6; fp["#{m}_#{j}"].tone.blue -= 6; fp["#{m}_#{j}"].tone.green -= 6
                end
                if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
                fp["#{m}_#{j}"].opacity -= 51
                else
                fp["#{m}_#{j}"].opacity += 51
                end
                fp["#{m}_#{j}"].visible = false if fp["#{m}_#{j}"].opacity <= 0
            end
            @scene.wait
        end
        if i.between?(0,15)
            @userSprite.ox += hornXMove
        end
    end
    16.times do
        fp["bg"].opacity -= 20
        @scene.wait(1,true)
    end
    @userSprite.ox = userOX
    pbDisposeSpriteHash(fp)
    @vector.reset if !@multiHit
end