class DataBoxEBDX  <  SpriteWrapper
  alias setUp_StatOverlay setUp
  def setUp
    setUp_StatOverlay
    if @battle.singleBattle?
      @sprites["boost1"] = Sprite.new(@viewport)
      @sprites["boost1"].bitmap = nil
      @sprites["boost1"].z = 100
      @sprites["boost1"].ex = @playerpoke ? 186 : 20
      @sprites["boost1"].ey = @playerpoke ? -136 : 27
      @sprites["boost1"].visible = false

      @sprites["boost2"] = Sprite.new(@viewport)
      @sprites["boost2"].bitmap = nil
      @sprites["boost2"].z = 100
      @sprites["boost2"].ex = @playerpoke ? 186 : 20
      @sprites["boost2"].ey = @playerpoke ? -120 : 43
      @sprites["boost2"].visible = false

      @sprites["boost3"] = Sprite.new(@viewport)
      @sprites["boost3"].bitmap = nil
      @sprites["boost3"].z = 100
      @sprites["boost3"].ex = @playerpoke ? 186 : 20
      @sprites["boost3"].ey = @playerpoke ? -104 : 59
      @sprites["boost3"].visible = false

      @sprites["boost4"] = Sprite.new(@viewport)
      @sprites["boost4"].bitmap = nil
      @sprites["boost4"].z = 100
      @sprites["boost4"].ex = @playerpoke ? 186 : 20
      @sprites["boost4"].ey = @playerpoke ? -88 : 75
      @sprites["boost4"].visible = false

      @sprites["boost5"] = Sprite.new(@viewport)
      @sprites["boost5"].bitmap = nil
      @sprites["boost5"].z = 100
      @sprites["boost5"].ex = @playerpoke ? 186 : 20
      @sprites["boost5"].ey = @playerpoke ? -72 : 91
      @sprites["boost5"].visible = false

      @sprites["boost6"] = Sprite.new(@viewport)
      @sprites["boost6"].bitmap = nil
      @sprites["boost6"].z = 100
      @sprites["boost6"].ex = @playerpoke ? 186 : 20
      @sprites["boost6"].ey = @playerpoke ? -56 : 107
      @sprites["boost6"].visible = false

      @sprites["boost7"] = Sprite.new(@viewport)
      @sprites["boost7"].bitmap = nil
      @sprites["boost7"].z = 100
      @sprites["boost7"].ex = @playerpoke ? 186 : 20
      @sprites["boost7"].ey = @playerpoke ? -40 : 123
      @sprites["boost7"].visible = false
    else
      @sprites["boost1"] = Sprite.new(@viewport)
      @sprites["boost1"].bitmap = nil
      @sprites["boost1"].z = 100
      @sprites["boost1"].ex = @playerpoke ? -106 : 242
      @sprites["boost1"].ey = -32
      @sprites["boost1"].visible = false

      @sprites["boost2"] = Sprite.new(@viewport)
      @sprites["boost2"].bitmap = nil
      @sprites["boost2"].z = 100
      @sprites["boost2"].ex = @playerpoke ? -106 : 242
      @sprites["boost2"].ey = -16
      @sprites["boost2"].visible = false

      @sprites["boost3"] = Sprite.new(@viewport)
      @sprites["boost3"].bitmap = nil
      @sprites["boost3"].z = 100
      @sprites["boost3"].ex = @playerpoke ? -106 : 242
      @sprites["boost3"].ey =0
      @sprites["boost3"].visible = false

      @sprites["boost4"] = Sprite.new(@viewport)
      @sprites["boost4"].bitmap = nil
      @sprites["boost4"].z = 100
      @sprites["boost4"].ex = @playerpoke ? -106 : 282
      @sprites["boost4"].ey = -32
      @sprites["boost4"].visible = false

      @sprites["boost5"] = Sprite.new(@viewport)
      @sprites["boost5"].bitmap = nil
      @sprites["boost5"].z = 100
      @sprites["boost5"].ex = @playerpoke ? -66 : 282
      @sprites["boost5"].ey = -16
      @sprites["boost5"].visible = false

      @sprites["boost6"] = Sprite.new(@viewport)
      @sprites["boost6"].bitmap = nil
      @sprites["boost6"].z = 100
      @sprites["boost6"].ex = @playerpoke ? -66 : 282
      @sprites["boost6"].ey = 0
      @sprites["boost6"].visible = false

      @sprites["boost7"] = Sprite.new(@viewport)
      @sprites["boost7"].bitmap = nil
      @sprites["boost7"].z = 100
      @sprites["boost7"].ex = @playerpoke ? -66 : 322
      @sprites["boost7"].ey = -32
      @sprites["boost7"].visible = false
    end
  end
  alias update_StatOverlay update
  def update
    update_StatOverlay
    # shows stat boosts
    stat_boost = []
    $stat_boost = stat_boost
    i = @battler.stages[:ATTACK]
    j = @battler.stages[:DEFENSE]
    k = @battler.stages[:SPECIAL_ATTACK]
    l = @battler.stages[:SPECIAL_DEFENSE]
    m = @battler.stages[:SPEED]
    n = @battler.stages[:ACCURACY]
    o = @battler.stages[:EVASION]
    stat_boost.push(i)
    stat_boost.push(j)
    stat_boost.push(k)
    stat_boost.push(l)
    stat_boost.push(m)
    stat_boost.push(n)
    stat_boost.push(o)
    @sprites["boost1"].bitmap = i != 0 ? pbBitmap(@path + "Atk#{i}") : nil
    @sprites["boost1"].visible = i != 0 ? true : false

    @sprites["boost2"].bitmap = j != 0 ? pbBitmap(@path + "Def#{j}") : nil
    @sprites["boost2"].visible = j != 0 ? true : false

    @sprites["boost3"].bitmap = k != 0 ? pbBitmap(@path + "SpAtk#{k}") : nil
    @sprites["boost3"].visible = k != 0 ? true : false

    @sprites["boost4"].bitmap = l != 0 ? pbBitmap(@path + "SpDef#{l}") : nil
    @sprites["boost4"].visible = l != 0 ? true : false

    @sprites["boost5"].bitmap = m != 0 ? pbBitmap(@path + "Spe#{m}") : nil
    @sprites["boost5"].visible = m != 0 ? true : false

    @sprites["boost6"].bitmap = n != 0 ? pbBitmap(@path + "Acc#{n}") : nil
    @sprites["boost6"].visible = n != 0 ? true : false

    @sprites["boost7"].bitmap = o != 0 ? pbBitmap(@path + "Eva#{o}") : nil
    @sprites["boost7"].visible = o != 0 ? true : false
  end
end
