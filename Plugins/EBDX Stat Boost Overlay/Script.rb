class DataBoxEBDX  <  SpriteWrapper
  alias setUp_StatOverlay setUp
  def setUp
    setUp_StatOverlay
    @showBoosts = true                          # No real reason to turn this off, unless you wanna tie this to a switch or smth lol
    @singleOnly = false                         # Only display stat boosts during single battles
    doublesSingleLine = true                    # Display stat boosts on a single line instead during double battles

    sXp = @battle.singleBattle? ? 172 : 172     # The horizontal position of the FIRST stat change on the Player's PKMN
    sYp = @battle.singleBattle? ? -46 : -36     # The vertical position of the FIRST stat change on the Player's PKMN
    sXe = @battle.singleBattle? ? 4 : 4         # The horizontal position of the FIRST stat change on the Opponent's PKMN
    sYe = @battle.singleBattle? ? 22 : 14       # The vertical position of the FIRST stat change on the Opponent's PKMN
    sXoffset = 46                               # The amount of horizontal space between stat changes
    sYoffset = 22                               # The amount of vertical space between stat changes
    statswidth = 4                              # The amount of stat changes displayed per line

    @statAmount = 7                             # How many stats to display. Unless you know what you're doing, don't change this.

    # Create the sprites (not visible yet)
    @statAmount.times do |i|
      bX = @playerpoke ? sXp : sXe
      bY = @playerpoke ? sYp : sYe
      # Ensure the player's boosts are right-aligned going up, while opp's boosts are left-aligned going down
      offsetX = @playerpoke ? sXoffset : (sXoffset * -1)
      offsetY = @playerpoke ? sYoffset : (sYoffset * -1)
      stackBoosts = @battle.singleBattle? || doublesSingleLine == false
      xOffsetPower = stackBoosts ? i % statswidth : i
      yOffsetPower = stackBoosts ? (i / statswidth).floor : 0

      @sprites["boost#{i+1}"] = Sprite.new(@viewport)
      @sprites["boost#{i+1}"].bitmap = nil
      @sprites["boost#{i+1}"].z = 1
      @sprites["boost#{i+1}"].ex = (bX - offsetX * xOffsetPower)
      @sprites["boost#{i+1}"].ey = (bY - offsetY * yOffsetPower)
      @sprites["boost#{i+1}"].visible = false
    end
  end
  alias update_StatOverlay update
  def update
    update_StatOverlay
    # Get all stat boosts
    stats = [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED,:ACCURACY,:EVASION]
    stat_boost = []
    @statAmount.times do |i|
      stat = stats[i.clamp(0,stats.length)] # Fail-safe
      stat_boost.push(stat) if @battler.stages[stat] != 0
    end

    # Assign correct sprite according to stat boosts
    @statAmount.times do |i|
      sprite = @sprites["boost#{i+1}"]
      showSprites = (@battle.singleBattle? || !@singleOnly) && @showBoosts
      if stat_boost.size > i && showSprites && self.visible # Makes the stat changes disappear if HP bar disappears lol
        stat = stat_boost[i]

        sprite.bitmap = pbBitmap(getBitmap(stat))
        getRect(sprite, stat)
        sprite.visible = true 
      else
        sprite.bitmap = nil
        sprite.visible = false
      end
    end
  end

  def getBitmap(stat)
    s = GameData::Stat.get(stat)
    string = @path + "changes_#{s.name_brief}"
    return string
  end

  def getRect(sprite, stat)
    iconWidth = 48
    iconHeight = 26
    stage = @battler.stages[stat]
    x = iconWidth * (stage > 0 ? 0 : 1)
    y = iconHeight * (stage.abs - 1)

    sprite.src_rect.set(x, y, iconWidth, iconHeight)
  end
end
