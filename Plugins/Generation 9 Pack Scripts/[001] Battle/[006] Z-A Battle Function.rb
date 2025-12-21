class Battle
  #=============================================================================
  # Aliased to add Tatsugiri commander effect.
  #=============================================================================
  alias za_pbCanMegaEvolve? pbCanMegaEvolve?
  def pbCanMegaEvolve?(idxBattler)
    return za_pbCanMegaEvolve?(idxBattler) &&
           !@battlers[idxBattler].effects[PBEffects::Commander]
  end

  #=============================================================================
  # Mega Evolving a battler
  #=============================================================================
  alias za_pbMegaEvolve pbMegaEvolve
  def pbMegaEvolve(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasMega? || battler.mega?
    za_pbMegaEvolve(idxBattler)
    if !defined?(battler.display_mega_moves)
      MultipleForms.call("changePokemonOnMegaEvolve", battler, self)
    end
  end

  #=============================================================================
  # Added Canari charms effects
  #=============================================================================
  alias za_pbGainExpOne pbGainExpOne
  def pbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages = true)
    canari_plushies = [:REDCANARIPLUSHLV3, :REDCANARIPLUSHLV2, :REDCANARIPLUSHLV1]
    if canari_plushies.none?{ |i| GameData::Item.exists?(i) }
      za_pbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages)
    else
      pkmn = pbParty(0)[idxParty]   # The Pokémon gaining Exp from defeatedBattler
      growth_rate = pkmn.growth_rate
      # Don't bother calculating if gainer is already at max Exp
      if pkmn.exp >= growth_rate.maximum_exp
        pkmn.calc_stats   # To ensure new EVs still have an effect
        return
      end
      isPartic    = defeatedBattler.participants.include?(idxParty)
      hasExpShare = expShare.include?(idxParty)
      level = defeatedBattler.level
      # Main Exp calculation
      exp = 0
      a = level * defeatedBattler.pokemon.base_exp
      if expShare.length > 0 && (isPartic || hasExpShare)
        if numPartic == 0   # No participants, all Exp goes to Exp Share holders
          exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? expShare.length : 1)
        elsif Settings::SPLIT_EXP_BETWEEN_GAINERS   # Gain from participating and/or Exp Share
          exp = a / (2 * numPartic) if isPartic
          exp += a / (2 * expShare.length) if hasExpShare
        else   # Gain from participating and/or Exp Share (Exp not split)
          exp = (isPartic) ? a : a / 2
        end
      elsif isPartic   # Participated in battle, no Exp Shares held by anyone
        exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? numPartic : 1)
      elsif expAll   # Didn't participate in battle, gaining Exp due to Exp All
        # NOTE: Exp All works like the Exp Share from Gen 6+, not like the Exp All
        #       from Gen 1, i.e. Exp isn't split between all Pokémon gaining it.
        exp = a / 2
      end
      return if exp <= 0
      # Pokémon gain more Exp from trainer battles
      exp = (exp * 1.5).floor if Settings::MORE_EXP_FROM_TRAINER_POKEMON && trainerBattle?
      # Scale the gained Exp based on the gainer's level (or not)
      if Settings::SCALED_EXP_FORMULA
        exp /= 5
        levelAdjust = ((2 * level) + 10.0) / (pkmn.level + level + 10.0)
        levelAdjust **= 5
        levelAdjust = Math.sqrt(levelAdjust)
        exp *= levelAdjust
        exp = exp.floor
        exp += 1 if isPartic || hasExpShare
      else
        exp /= 7
      end
      # Foreign Pokémon gain more Exp
      isOutsider = (pkmn.owner.id != pbPlayer.id ||
                  (pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language))
      if isOutsider
        if pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language
          exp = (exp * 1.7).floor
        else
          exp = (exp * 1.5).floor
        end
      end
      # Exp. Charm increases Exp gained
      if $bag.has?(:EXPCHARM)
        exp = exp * 3 / 2
      else
        # Canari Charm increases Exp gained
        canari_plushies.each_with_index do |plush, i|
          next if !GameData::Item.exists?(plush) || !$bag.has?(plush)
          exp = (exp * [1.15, 1.10, 1.05][i]).floor
          break
        end
      end
      # Modify Exp gain based on pkmn's held item
      i = Battle::ItemEffects.triggerExpGainModifier(pkmn.item, pkmn, exp)
      if i < 0
        i = Battle::ItemEffects.triggerExpGainModifier(@initialItems[0][idxParty], pkmn, exp)
      end
      exp = i if i >= 0
      # Boost Exp gained with high affection
      if Settings::AFFECTION_EFFECTS && @internalBattle && pkmn.affection_level >= 4 && !pkmn.mega?
        exp = exp * 6 / 5
        isOutsider = true   # To show the "boosted Exp" message
      end
      # Make sure Exp doesn't exceed the maximum
      expFinal = growth_rate.add_exp(pkmn.exp, exp)
      expGained = expFinal - pkmn.exp
      return if expGained <= 0
      # "Exp gained" message
      if showMessages
        if isOutsider
          pbDisplayPaused(_INTL("{1} got a boosted {2} Exp. Points!", pkmn.name, expGained))
        else
          pbDisplayPaused(_INTL("{1} got {2} Exp. Points!", pkmn.name, expGained))
        end
      end
      curLevel = pkmn.level
      newLevel = growth_rate.level_from_exp(expFinal)
      if newLevel < curLevel
        debugInfo = "Levels: #{curLevel}->#{newLevel} | Exp: #{pkmn.exp}->#{expFinal} | gain: #{expGained}"
        raise _INTL("{1}'s new level is less than its current level, which shouldn't happen.", pkmn.name) + "\n[#{debugInfo}]"
      end
      # Give Exp
      if pkmn.shadowPokemon?
        if pkmn.heartStage <= 3
          pkmn.exp += expGained
          $stats.total_exp_gained += expGained
        end
        return
      end
      $stats.total_exp_gained += expGained
      tempExp1 = pkmn.exp
      battler = pbFindBattler(idxParty)
      loop do   # For each level gained in turn...
        # EXP Bar animation
        levelMinExp = growth_rate.minimum_exp_for_level(curLevel)
        levelMaxExp = growth_rate.minimum_exp_for_level(curLevel + 1)
        tempExp2 = (levelMaxExp < expFinal) ? levelMaxExp : expFinal
        pkmn.exp = tempExp2
        @scene.pbEXPBar(battler, levelMinExp, levelMaxExp, tempExp1, tempExp2)
        tempExp1 = tempExp2
        curLevel += 1
        if curLevel > newLevel
          # Gained all the Exp now, end the animation
          pkmn.calc_stats
          battler&.pbUpdate(false)
          @scene.pbRefreshOne(battler.index) if battler
          break
        end
        # Levelled up
        pbCommonAnimation("LevelUp", battler) if battler
        oldTotalHP = pkmn.totalhp
        oldAttack  = pkmn.attack
        oldDefense = pkmn.defense
        oldSpAtk   = pkmn.spatk
        oldSpDef   = pkmn.spdef
        oldSpeed   = pkmn.speed
        battler.pokemon.changeHappiness("levelup") if battler&.pokemon
        pkmn.calc_stats
        battler&.pbUpdate(false)
        @scene.pbRefreshOne(battler.index) if battler
        pbDisplayPaused(_INTL("{1} grew to Lv. {2}!", pkmn.name, curLevel)) { pbSEPlay("Pkmn level up") }
        @scene.pbLevelUp(pkmn, battler, oldTotalHP, oldAttack, oldDefense,
                        oldSpAtk, oldSpDef, oldSpeed)
        # Learn all moves learned at this level
        moveList = pkmn.getMoveList
        moveList.each { |m| pbLearnMove(idxParty, m[1]) if m[0] == curLevel }
      end
    end
  end

  #=============================================================================
  # Added Canari charms effects
  #=============================================================================
  alias za_pbGainMoney pbGainMoney
  def pbGainMoney
    return if !@internalBattle || !@moneyGain
    canari_plushies = [:GOLDCANARIPLUSHLV3, :GOLDCANARIPLUSHLV2, :GOLDCANARIPLUSHLV1]
    if canari_plushies.none?{ |i| GameData::Item.exists?(i) }
      za_pbGainMoney
    else
      plush_mult = 1
      # Canari Charm mult modifier
      canari_plushies.each_with_index do |plush, i|
        next if !GameData::Item.exists?(plush) || !$bag.has?(plush)
        plush_mult = [1.5, 1.3, 1.15][i]
        break
      end
      # Money rewarded from opposing trainers
      if trainerBattle?
        tMoney = 0
        @opponent.each_with_index do |t, i|
          tMoney += pbMaxLevelInTeam(1, i) * t.base_money
        end
        tMoney *= 2 if @field.effects[PBEffects::AmuletCoin]
        tMoney *= 2 if @field.effects[PBEffects::HappyHour]
        tMoney *= plush_mult
        oldMoney = pbPlayer.money
        pbPlayer.money += tMoney
        moneyGained = pbPlayer.money - oldMoney
        if moneyGained > 0
          $stats.battle_money_gained += moneyGained
          pbDisplayPaused(_INTL("You got ${1} for winning!", moneyGained.to_s_formatted))
        end
      end
      # Pick up money scattered by Pay Day
      if @field.effects[PBEffects::PayDay] > 0
        @field.effects[PBEffects::PayDay] *= 2 if @field.effects[PBEffects::AmuletCoin]
        @field.effects[PBEffects::PayDay] *= 2 if @field.effects[PBEffects::HappyHour]
        @field.effects[PBEffects::PayDay] *= plush_mult
        oldMoney = pbPlayer.money
        pbPlayer.money += @field.effects[PBEffects::PayDay]
        moneyGained = pbPlayer.money - oldMoney
        if moneyGained > 0
          $stats.battle_money_gained += moneyGained
          pbDisplayPaused(_INTL("You picked up ${1}!", moneyGained.to_s_formatted))
        end
      end
    end
  end

  #=============================================================================
  # Calculate how many shakes a thrown Poké Ball will make (4 = capture)
  #=============================================================================
  alias za_pbCaptureCalc pbCaptureCalc
  def pbCaptureCalc(pkmn, battler, catch_rate, ball)
    return 4 if $DEBUG && Input.press?(Input::CTRL)
    # Get a catch rate if one wasn't provided
    catch_rate = pkmn.species_data.catch_rate if !catch_rate
    
    canari_plushies = [:BLUECANARIPLUSHLV3, :BLUECANARIPLUSHLV2, :BLUECANARIPLUSHLV1]
    # Canari Charm increases catch rate
    canari_plushies.each_with_index do |plush, i|
      next if !GameData::Item.exists?(plush) || !$bag.has?(plush)
      catch_rate = catch_rate * [1.35, 1.20, 1.10][i]
      break
    end
    return za_pbCaptureCalc(pkmn, battler, catch_rate, ball)
  end
end