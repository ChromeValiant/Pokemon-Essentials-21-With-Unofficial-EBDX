################################################################################
# 
# Updates to old move effects.
# 
################################################################################

#===============================================================================
# Psycho Shift
#===============================================================================
# Adds messages for Drowsy/Frostbite.
#-------------------------------------------------------------------------------
class Battle::Move::GiveUserStatusToTarget < Battle::Move
  alias paldea_pbEffectAgainstTarget pbEffectAgainstTarget
  def pbEffectAgainstTarget(user, target)
    if [:DROWSY, :FROSTBITE].include?(user.status)
      case user.status
      when :DROWSY
        target.pbSleep
        user.pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1} became alert again.", user.pbThis))
      when :FROSTBITE
        target.pbFreeze
        user.pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1}'s frostbite was healed.", user.pbThis))
      end
    else
      paldea_pbEffectAgainstTarget(user, target)
    end
  end
end

#===============================================================================
# Aromatherapy, Heal Bell
#===============================================================================
# Adds messages for Drowsy/Frostbite.
#-------------------------------------------------------------------------------
class Battle::Move::CureUserPartyStatus < Battle::Move
  def pbAromatherapyHeal(pkmn, battler = nil)
    oldStatus = (battler) ? battler.status : pkmn.status
    curedName = (battler) ? battler.pbThis : pkmn.name
    if battler
      battler.pbCureStatus(false)
    else
      pkmn.status      = :NONE
      pkmn.statusCount = 0
    end
    case oldStatus
    when :SLEEP
      @battle.pbDisplay(_INTL("{1} was woken from sleep.", curedName))
    when :POISON
      @battle.pbDisplay(_INTL("{1} was cured of its poisoning.", curedName))
    when :BURN
      @battle.pbDisplay(_INTL("{1}'s burn was healed.", curedName))
    when :PARALYSIS
      @battle.pbDisplay(_INTL("{1} was cured of paralysis.", curedName))
    when :FROZEN
      @battle.pbDisplay(_INTL("{1} was thawed out.", curedName))
    when :DROWSY
      @battle.pbDisplay(_INTL("{1} became alert again.", curedName))
    when :FROSTBITE
      @battle.pbDisplay(_INTL("{1}'s frostbite was healed.", curedName))
    end
  end
end

#===============================================================================
# Jungle Healing
#===============================================================================
# Adds messages for Drowsy/Frostbite.
#-------------------------------------------------------------------------------
class Battle::Move::HealUserAndAlliesQuarterOfTotalHPCureStatus < Battle::Move
  def pbEffectAgainstTarget(user, target)
    if target.canHeal?
      target.pbRecoverHP(target.totalhp / 4)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
    end
    if target.status != :NONE
      old_status = target.status
      target.pbCureStatus(false)
      case old_status
      when :SLEEP
        @battle.pbDisplay(_INTL("{1} was woken from sleep.", target.pbThis))
      when :POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poisoning.", target.pbThis))
      when :BURN
        @battle.pbDisplay(_INTL("{1}'s burn was healed.", target.pbThis))
      when :PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of paralysis.", target.pbThis))
      when :FROZEN
        @battle.pbDisplay(_INTL("{1} was thawed out.", target.pbThis))
      when :DROWSY
        @battle.pbDisplay(_INTL("{1} became alert again.", target.pbThis))
      when :FROSTBITE
        @battle.pbDisplay(_INTL("{1}'s frostbite was healed.", target.pbThis))
      end
    end
  end
end

#===============================================================================
# Wake-Up Slap
#===============================================================================
# Adds Drowsiness as a status that is removed from the target after being hit.
#-------------------------------------------------------------------------------
class Battle::Move::DoublePowerIfTargetAsleepCureTarget < Battle::Move
  def pbEffectAfterAllHits(user, target)
    return if target.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if ![:SLEEP, :DROWSY].include?(target.status)
    target.pbCureStatus
  end
end

#===============================================================================
# Uproar
#===============================================================================
# Adds Drowsiness as a status that is removed from battlers.
#-------------------------------------------------------------------------------
class Battle::Move::MultiTurnAttackPreventSleeping < Battle::Move
  def pbEffectGeneral(user)
    return if user.effects[PBEffects::Uproar] > 0
    user.effects[PBEffects::Uproar] = 3
    user.currentMove = @id
    @battle.pbDisplay(_INTL("{1} caused an uproar!", user.pbThis))
    @battle.pbPriority(true).each do |b|
      next if b.fainted? || ![:SLEEP, :DROWSY].include?(b.status)
      next if b.hasActiveAbility?(:SOUNDPROOF)
      b.pbCureStatus
    end
  end
end

#===============================================================================
# Rest
#===============================================================================
# Adds failure check with the Purifying Salt ability.
#-------------------------------------------------------------------------------
class Battle::Move::HealUserFullyAndFallAsleep < Battle::Move::HealingMove
  alias paldea_pbMoveFailed? pbMoveFailed?
  def pbMoveFailed?(user, targets)
    if user.hasActiveAbility?(:PURIFYINGSALT)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return paldea_pbMoveFailed?(user, targets)
  end
end  

#===============================================================================
# Roar, Whirlwind
#===============================================================================
# Adds Guard Dog immunity.
#-------------------------------------------------------------------------------
class Battle::Move::SwitchOutTargetStatusMove < Battle::Move
  alias paldea_pbFailsAgainstTarget? pbFailsAgainstTarget?
  def pbFailsAgainstTarget?(user, target, show_message)
	if target.isCommander?
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if target.hasActiveAbility?(:GUARDDOG) && !@battle.moldBreaker
      if show_message
        @battle.pbShowAbilitySplash(target)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} anchors itself!", target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} anchors itself with {2}!", target.pbThis, target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
      end
      return true
    end
    return paldea_pbFailsAgainstTarget?(user, target, show_message)
  end

  def pbSwitchOutTargetEffect(user, targets, numHits, switched_battlers)
    return if !switched_battlers.empty?
    return if user.fainted? || numHits == 0
    targets.each do |b|
      next if b.fainted? || b.damageState.unaffected
      next if b.wild?
      next if b.effects[PBEffects::Ingrain]
      next if b.hasActiveAbility?([:SUCTIONCUPS, :GUARDDOG]) && !@battle.moldBreaker
      next if b.isCommander?
      newPkmn = @battle.pbGetReplacementPokemonIndex(b.index, true)
      next if newPkmn < 0
      @battle.pbRecallAndReplace(b.index, newPkmn, true)
      @battle.pbDisplay(_INTL("{1} was dragged out!", b.pbThis))
      @battle.pbClearChoice(b.index)
      @battle.pbOnBattlerEnteringBattle(b.index)
      switched_battlers.push(b.index)
      break
    end
  end
end

#===============================================================================
# Circle Throw, Dragon Tail
#===============================================================================
# Adds Guard Dog immunity to effect only (may still take damage).
#-------------------------------------------------------------------------------
class Battle::Move::SwitchOutTargetDamagingMove < Battle::Move
  def pbSwitchOutTargetEffect(user, targets, numHits, switched_battlers)
    return if @battle.wildBattle? || !switched_battlers.empty?
    return if user.fainted? || numHits == 0
    targets.each do |b|
      next if b.fainted? || b.damageState.unaffected || b.damageState.substitute
      next if b.effects[PBEffects::Ingrain]
      next if b.hasActiveAbility?([:SUCTIONCUPS, :GUARDDOG]) && !@battle.moldBreaker
      next if b.isCommander?
      newPkmn = @battle.pbGetReplacementPokemonIndex(b.index, true)
      next if newPkmn < 0
      @battle.pbRecallAndReplace(b.index, newPkmn, true)
      @battle.pbDisplay(_INTL("{1} was dragged out!", b.pbThis))
      @battle.pbClearChoice(b.index)
      @battle.pbOnBattlerEnteringBattle(b.index)
      switched_battlers.push(b.index)
      break
    end
  end
end

#===============================================================================
# Tailwind
#===============================================================================
# Adds Wind Rider and Wind Power procs.
#-------------------------------------------------------------------------------
class Battle::Move::StartUserSideDoubleSpeed < Battle::Move
  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::Tailwind] = 4
    @battle.pbDisplay(_INTL("The Tailwind blew from behind {1}!", user.pbTeam(true)))
    @battle.allSameSideBattlers(user).each do |b|
      next if !b || b.fainted?
      if b.hasActiveAbility?(:WINDRIDER) && b.pbCanRaiseStatStage?(:ATTACK, b, self)
        b.pbRaiseStatStageByAbility(:ATTACK, 1, b)
      elsif b.hasActiveAbility?(:WINDPOWER) && b.effects[PBEffects::Charge] == 0
        @battle.pbShowAbilitySplash(b)
        b.effects[PBEffects::Charge] = 2
        @battle.pbDisplay(_INTL("Being hit by Tailwind charged {1} with power!", b.pbThis(true)))
        @battle.pbHideAbilitySplash(b)
      end
    end
  end
end

#===============================================================================
# Ally Switch
#===============================================================================
# Allows Ally Switch to function like it does in Gen 9 if MECHANICS_GENERATION >= 9.
#-------------------------------------------------------------------------------
class Battle::Move::UserSwapsPositionsWithAlly < Battle::Move
  def pbChangeUsageCounters(user, specialUsage)
    oldVal = user.effects[PBEffects::ProtectRate]
    super
    user.effects[PBEffects::ProtectRate] = oldVal
  end

  def pbMoveFailed?(user, targets)
    if Settings::MECHANICS_GENERATION >= 9
      if user.effects[PBEffects::AllySwitch]
        user.effects[PBEffects::ProtectRate] = 1
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if user.effects[PBEffects::ProtectRate] > 1 &&
         @battle.pbRandom(user.effects[PBEffects::ProtectRate]) != 0
        user.effects[PBEffects::ProtectRate] = 1
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    end
    numTargets = 0
    if !user.effects[PBEffects::Commander]
      @idxAlly = -1
      idxUserOwner = @battle.pbGetOwnerIndexFromBattlerIndex(user.index)
      user.allAllies.each do |b|
        next if @battle.pbGetOwnerIndexFromBattlerIndex(b.index) != idxUserOwner
        next if !b.near?(user)
        next if b.effects[PBEffects::Commander]
        numTargets += 1
        @idxAlly = b.index
      end
    end
    if numTargets != 1
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
  
  alias paldea_pbEffectGeneral pbEffectGeneral
  def pbEffectGeneral(user)
    if Settings::MECHANICS_GENERATION >= 9
      user.effects[PBEffects::AllySwitch] = true
      user.effects[PBEffects::ProtectRate] *= 3
    end
    paldea_pbEffectGeneral(user)
  end
end

#===============================================================================
# Fling
#===============================================================================
# Adds Covert Cloak immunity to added effects from flung items.
#-------------------------------------------------------------------------------
class Battle::Move::ThrowUserItemAtTarget < Battle::Move
  def pbEffectAgainstTarget(user, target)
    return if target.damageState.substitute
    return if target.hasActiveItem?(:COVERTCLOAK)
    return if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
    case user.item_id
    when :POISONBARB
      target.pbPoison(user) if target.pbCanPoison?(user, false, self)
    when :TOXICORB
      target.pbPoison(user, nil, true) if target.pbCanPoison?(user, false, self)
    when :FLAMEORB
      target.pbBurn(user) if target.pbCanBurn?(user, false, self)
    when :LIGHTBALL
      target.pbParalyze(user) if target.pbCanParalyze?(user, false, self)
    when :KINGSROCK, :RAZORFANG
      target.pbFlinch(user)
    else
      target.pbHeldItemTriggerCheck(user.item, true)
    end
  end
end

#===============================================================================
# Fury Swipes, Bullet Seed, etc. (2-5 hit moves)
#===============================================================================
# Adds Loaded Dice bonus to allow these moves to always hit 4-5 times.
#-------------------------------------------------------------------------------
class Battle::Move::HitTwoToFiveTimes < Battle::Move
  alias paldea_pbNumHits pbNumHits
  def pbNumHits(user, targets)
    return 4 + @battle.pbRandom(2) if user.hasActiveItem?(:LOADEDDICE)
    return paldea_pbNumHits(user, targets)
  end
end

#===============================================================================
# Triple Kick
#===============================================================================
# Adds Loaded Dice bonus bypassing additional accuracy checks per hit.
#-------------------------------------------------------------------------------
class Battle::Move::HitThreeTimesPowersUpWithEachHit < Battle::Move
  def pbOnStartUse(user, targets)
    @calcBaseDmg = 0
    @accCheckPerHit = !user.hasActiveAbility?(:SKILLLINK) && !user.hasActiveItem?(:LOADEDDICE)
  end
end

#===============================================================================
# Role Play
#===============================================================================
# Fails if user is holding an Ability Shield.
#-------------------------------------------------------------------------------
class Battle::Move::SetUserAbilityToTargetAbility < Battle::Move
  alias paldea_pbMoveFailed? pbMoveFailed?
  def pbMoveFailed?(user, targets)
    if user.hasActiveItem?(:ABILITYSHIELD)
      @battle.pbDisplay(_INTL("{1}'s Ability is protected by the effects of its Ability Shield!", user.pbThis))
      return true
    end
    return paldea_pbMoveFailed?(user, targets)
  end
end

#===============================================================================
# Skill Swap
#===============================================================================
# Adds Ability Shield immunity. Fails if user is holding an Ability Shield.
#-------------------------------------------------------------------------------
class Battle::Move::UserTargetSwapAbilities < Battle::Move
  alias paldea_pbMoveFailed? pbMoveFailed?
  def pbMoveFailed?(user, targets)
    if user.hasActiveItem?(:ABILITYSHIELD)
      @battle.pbDisplay(_INTL("{1}'s Ability is protected by the effects of its Ability Shield!", user.pbThis))
      return true
    end
    return paldea_pbMoveFailed?(user, targets)
  end
  
  alias paldea_pbFailsAgainstTarget? pbFailsAgainstTarget?
  def pbFailsAgainstTarget?(user, target, show_message)
    ret = paldea_pbFailsAgainstTarget?(user, target, show_message)
    if !ret && target.hasActiveItem?(:ABILITYSHIELD)
      @battle.pbDisplay(_INTL("{1}'s Ability is protected by the effects of its Ability Shield!", target.pbThis)) if show_message
      return true
    end
    return ret
  end
end

#===============================================================================
# Entrainment
#===============================================================================
# Adds Ability Shield immunity.
#-------------------------------------------------------------------------------
class Battle::Move::SetTargetAbilityToUserAbility < Battle::Move
  alias paldea_pbFailsAgainstTarget? pbFailsAgainstTarget?
  def pbFailsAgainstTarget?(user, target, show_message)
    ret = paldea_pbFailsAgainstTarget?(user, target, show_message)
    if !ret && target.hasActiveItem?(:ABILITYSHIELD)
      @battle.pbDisplay(_INTL("{1}'s Ability is protected by the effects of its Ability Shield!", target.pbThis)) if show_message
      return true
    end
    return ret
  end
end

#===============================================================================
# Worry Seed
#===============================================================================
# Adds Ability Shield immunity.
#-------------------------------------------------------------------------------
class Battle::Move::SetTargetAbilityToInsomnia < Battle::Move
  alias paldea_pbFailsAgainstTarget? pbFailsAgainstTarget?
  def pbFailsAgainstTarget?(user, target, show_message)
    ret = paldea_pbFailsAgainstTarget?(user, target, show_message)
    if !ret && target.hasActiveItem?(:ABILITYSHIELD)
      @battle.pbDisplay(_INTL("{1}'s Ability is protected by the effects of its Ability Shield!", target.pbThis)) if show_message
      return true
    end
    return ret
  end
end

#===============================================================================
# Simple Beam
#===============================================================================
# Adds Ability Shield immunity.
#-------------------------------------------------------------------------------
class Battle::Move::SetTargetAbilityToSimple < Battle::Move
  alias paldea_pbFailsAgainstTarget? pbFailsAgainstTarget?
  def pbFailsAgainstTarget?(user, target, show_message)
    ret = paldea_pbFailsAgainstTarget?(user, target, show_message)
    if !ret && target.hasActiveItem?(:ABILITYSHIELD)
      @battle.pbDisplay(_INTL("{1}'s Ability is protected by the effects of its Ability Shield!", target.pbThis)) if show_message
      return true
    end
    return ret
  end
end

#===============================================================================
# Gastro Acid
#===============================================================================
# Adds Ability Shield immunity.
#-------------------------------------------------------------------------------
class Battle::Move::NegateTargetAbility < Battle::Move
  alias paldea_pbFailsAgainstTarget? pbFailsAgainstTarget?
  def pbFailsAgainstTarget?(user, target, show_message)
    ret = paldea_pbFailsAgainstTarget?(user, target, show_message)
    if !ret && target.hasActiveItem?(:ABILITYSHIELD)
      @battle.pbDisplay(_INTL("{1}'s Ability is protected by the effects of its Ability Shield!", target.pbThis)) if show_message
      return true
    end
    return ret
  end
end

#===============================================================================
# Core Enforcer
#===============================================================================
# Adds Ability Shield immunity to effect only (may still take damage).
#-------------------------------------------------------------------------------
class Battle::Move::NegateTargetAbilityIfTargetActed < Battle::Move
  alias paldea_pbEffectAgainstTarget pbEffectAgainstTarget
  def pbEffectAgainstTarget(user, target)
    return if target.hasActiveItem?(:ABILITYSHIELD)
    paldea_pbEffectAgainstTarget(user, target)
  end
end

#===============================================================================
# Sunsteel Strike, Moongeist Beam
#===============================================================================
# Adds Ability Shield immunity.
#-------------------------------------------------------------------------------
class Battle::Move::IgnoreTargetAbility < Battle::Move
  def pbOnStartUse(user, targets)
    if @battle.moldBreaker && targets[0].hasActiveItem?(:ABILITYSHIELD)
      @battle.moldBreaker = false
    end
  end
end

#===============================================================================
# Photon Geyser
#===============================================================================
# Adds Ability Shield immunity.
#-------------------------------------------------------------------------------
class Battle::Move::CategoryDependsOnHigherDamageIgnoreTargetAbility < Battle::Move::IgnoreTargetAbility
  alias paldea_pbOnStartUse pbOnStartUse
  def pbOnStartUse(user, targets)
    paldea_pbOnStartUse(user, targets)
    if @battle.moldBreaker && targets[0].hasActiveItem?(:ABILITYSHIELD)
      @battle.moldBreaker = false
    end
  end
end

#===============================================================================
# Belly Drum
#===============================================================================
# Allows Mirror Herb/Opportunist to copy the stat boosts granted by this move.
#-------------------------------------------------------------------------------
class Battle::Move::MaxUserAttackLoseHalfOfTotalHP < Battle::Move
  def pbEffectGeneral(user)
    hpLoss = [user.totalhp / 2, 1].max
    user.pbReduceHP(hpLoss, false, false)
    if user.hasActiveAbility?(:CONTRARY)
      user.stages[:ATTACK] = -6
      user.statsLoweredThisRound = true
      user.statsDropped = true
      @battle.pbCommonAnimation("StatDown", user)
      @battle.pbDisplay(_INTL("{1} cut its own HP and minimized its Attack!", user.pbThis))
    else
      user.stages[:ATTACK] = 6
      user.addSideStatUps(:ATTACK, 6)
      user.statsRaisedThisRound = true
      @battle.pbCommonAnimation("StatUp", user)
      @battle.pbDisplay(_INTL("{1} cut its own HP and maximized its Attack!", user.pbThis))
    end
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# OHKO moves
#===============================================================================
# Adds accuracy check for Glaive Rush effect.
#-------------------------------------------------------------------------------
class Battle::Move::OHKO < Battle::Move::FixedDamageMove
  alias paldea_pbAccuracyCheck pbAccuracyCheck
  def pbAccuracyCheck(user, target)
    return false if target.isCommander?
    return true if target.effects[PBEffects::GlaiveRush] > 0
    return paldea_pbAccuracyCheck(user, target)
  end
end

#===============================================================================
# Sheer Cold
#===============================================================================
# Adds accuracy check for Glaive Rush effect.
#-------------------------------------------------------------------------------
class Battle::Move::OHKOIce < Battle::Move::OHKO
  alias paldea_pbAccuracyCheck pbAccuracyCheck
  def pbAccuracyCheck(user, target)
    return false if target.isCommander?
    return true if target.effects[PBEffects::GlaiveRush] > 0
    return paldea_pbAccuracyCheck(user, target)
  end
end

#===============================================================================
# Defog
#===============================================================================
# Adds a check for abilities to trigger after terrain ends.
#-------------------------------------------------------------------------------
class Battle::Move::LowerTargetEvasion1RemoveSideEffects < Battle::Move::TargetStatDownMove
  alias paldea_pbEffectAgainstTarget pbEffectAgainstTarget
  def pbEffectAgainstTarget(user, target)
    old_terrain = @battle.field.terrain
    paldea_pbEffectAgainstTarget(user, target)
    if old_terrain != :None
      @battle.allBattlers.each { |b| b.pbAbilityOnTerrainChange }
    end
  end
end

#===============================================================================
# Judgment
#===============================================================================
# Adds Legend Plate functionality.
#-------------------------------------------------------------------------------
class Battle::Move::TypeDependsOnUserPlate < Battle::Move
  def pbOnStartUse(user, targets)
    if user.hasLegendPlateJudgment? && !targets.empty?
      target = nil
      targets.each do |b|
        next if !b || b.fainted? || b.isCommander?
        target = b
      end
      newType   = @battle.pbGetBestTypeJudgment(user, target, self, user.legendPlateType)
      newForm   = GameData::Type.get(newType).icon_position
      typeName  = GameData::Type.get(newType).name
      @calcType = newType
      if user.form != newForm
        @battle.scene.pbArceusTransform(user.index, newType)
        user.pbChangeForm(newForm,
        _INTL("{1} transformed into the {2} type!", user.pbThis, typeName))
      end
    end
  end

  alias paldea_pbBaseType pbBaseType
  def pbBaseType(user)
    if user.hasLegendPlateJudgment?
      return user.legendPlateType
    else
      return paldea_pbBaseType(user)
    end
  end
end

#===============================================================================
# Hidden Power
#===============================================================================
# Added Tooglable PLA Hidden Power.
#-------------------------------------------------------------------------------
class Battle::Move::TypeDependsOnUserIVs < Battle::Move
  def pbOnStartUse(user, targets)
    if Settings::HIDDEN_POWER_USE_PLA_MECHANICS && user.hasHiddenPowerUnown? && !targets.empty?
      target = nil
      targets.each do |b|
        next if !b || b.fainted? || b.isCommander?
        target = b
      end
      newType   = @battle.pbGetBestTypeJudgment(user, target, self, user.legendPlateType)
      @calcType = newType
    end
  end

  def pbBaseType(user)
    if Settings::HIDDEN_POWER_USE_PLA_MECHANICS
      return user.legendPlateType
    else
      hp = pbHiddenPower(user.pokemon)
      return hp[0]
    end
  end

  def pbBaseDamage(baseDmg, user, target)
    return 50 if Settings::HIDDEN_POWER_USE_PLA_MECHANICS
    return super if Settings::MECHANICS_GENERATION >= 6
    hp = pbHiddenPower(user.pokemon)
    return hp[1]
  end
end

#===============================================================================
# Feint
#===============================================================================
# Also negates the effects of Burning Bulwark.
#-------------------------------------------------------------------------------
class Battle::Move::RemoveProtections < Battle::Move
  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::BurningBulwark]         = false
    target.effects[PBEffects::BanefulBunker]          = false
    target.effects[PBEffects::KingsShield]            = false
    target.effects[PBEffects::Obstruct]               = false
    target.effects[PBEffects::Protect]                = false
    target.effects[PBEffects::SpikyShield]            = false
    target.pbOwnSide.effects[PBEffects::CraftyShield] = false
    target.pbOwnSide.effects[PBEffects::MatBlock]     = false
    target.pbOwnSide.effects[PBEffects::QuickGuard]   = false
    target.pbOwnSide.effects[PBEffects::WideGuard]    = false
  end
end

#===============================================================================
# Hyperspace Fury
#===============================================================================
# Also negates the effects of Burning Bulwark.
#-------------------------------------------------------------------------------
class Battle::Move::HoopaRemoveProtectionsBypassSubstituteLowerUserDef1 < Battle::Move::StatDownMove
  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::BurningBulwark]         = false
    target.effects[PBEffects::BanefulBunker]          = false
    target.effects[PBEffects::KingsShield]            = false
    target.effects[PBEffects::Obstruct]               = false
    target.effects[PBEffects::Protect]                = false
    target.effects[PBEffects::SpikyShield]            = false
    target.pbOwnSide.effects[PBEffects::CraftyShield] = false
    target.pbOwnSide.effects[PBEffects::MatBlock]     = false
    target.pbOwnSide.effects[PBEffects::QuickGuard]   = false
    target.pbOwnSide.effects[PBEffects::WideGuard]    = false
  end
end

#===============================================================================
# Shadow Force, Phantom Force
#===============================================================================
# Also negates the effects of Burning Bulwark.
#-------------------------------------------------------------------------------
class Battle::Move::TwoTurnAttackInvulnerableRemoveProtections < Battle::Move::TwoTurnMove
  def pbAttackingTurnEffect(user, target)
    target.effects[PBEffects::BurningBulwark]         = false
    target.effects[PBEffects::BanefulBunker]          = false
    target.effects[PBEffects::KingsShield]            = false
    target.effects[PBEffects::Obstruct]               = false
    target.effects[PBEffects::Protect]                = false
    target.effects[PBEffects::SpikyShield]            = false
    target.pbOwnSide.effects[PBEffects::CraftyShield] = false
    target.pbOwnSide.effects[PBEffects::MatBlock]     = false
    target.pbOwnSide.effects[PBEffects::QuickGuard]   = false
    target.pbOwnSide.effects[PBEffects::WideGuard]    = false
  end
end

#===============================================================================
# Sketch
#===============================================================================
# Updated blacklist to Gen 9 standards.
#-------------------------------------------------------------------------------
class Battle::Move::ReplaceMoveWithTargetLastMoveUsed < Battle::Move
  alias paldea_initialize initialize
  def initialize(battle, move)
    paldea_initialize(battle, move)
    @moveBlacklist.push(
      "SleepTargetIfUserDarkrai",                            # Dark Void
      "HoopaRemoveProtectionsBypassSubstituteLowerUserDef1", # Hyperspace Fury
      "TypeDependsOnUserMorpekoFormRaiseUserSpeed1",         # Aura Wheel
      "StarmobileBurnTarget",                                # Blazing Torque
      "StarmobileParalyzeTarget",                            # Combat Torque
      "StarmobileConfuseTarget",                             # Magical Torque
      "StarmobilePoisonTarget",                              # Noxious Torque
      "StarmobileSleepTarget",                               # Wicked Torque
      "RevivePokemonHalfHP",                                 # Revival Blessing
      "TerapagosCategoryDependsOnHigherDamage"               # Tera Starstorm
    )
  end
end

#===============================================================================
# Copycat
#===============================================================================
# Added several Gen 9 moves to blacklist.
#-------------------------------------------------------------------------------
class Battle::Move::UseLastMoveUsed < Battle::Move
  alias paldea_initialize initialize
  def initialize(battle, move)
    paldea_initialize(battle, move)
    @moveBlacklist.push(
      "StarmobileBurnTarget",                  # Blazing Torque
      "StarmobileParalyzeTarget",              # Combat Torque
      "StarmobileConfuseTarget",               # Magical Torque
      "StarmobilePoisonTarget",                # Noxious Torque
      "StarmobileSleepTarget",                 # Wicked Torque
      "ProtectUserBurningBulwark",             # Burning Bulwark
      "TerapagosCategoryDependsOnHigherDamage" # Tera Starstorm
    )
  end
end

#===============================================================================
# Assist
#===============================================================================
# Added several Gen 9 moves to blacklist.
#-------------------------------------------------------------------------------
class Battle::Move::UseRandomMoveFromUserParty < Battle::Move
  alias paldea_initialize initialize
  def initialize(battle, move)
    paldea_initialize(battle, move)
    @moveBlacklist.push(
      "StarmobileBurnTarget",                  # Blazing Torque
      "StarmobileParalyzeTarget",              # Combat Torque
      "StarmobileConfuseTarget",               # Magical Torque
      "StarmobilePoisonTarget",                # Noxious Torque
      "StarmobileSleepTarget",                 # Wicked Torque
      "ProtectUserBurningBulwark",             # Burning Bulwark
      "TerapagosCategoryDependsOnHigherDamage" # Tera Starstorm
    )
  end
end

#===============================================================================
# Mimic
#===============================================================================
# Added several Gen 9 moves to blacklist.
#-------------------------------------------------------------------------------
class Battle::Move::ReplaceMoveThisBattleWithTargetLastMoveUsed < Battle::Move
  alias paldea_initialize initialize
  def initialize(battle, move)
    paldea_initialize(battle, move)
    @moveBlacklist.push(
      "StarmobileBurnTarget",                  # Blazing Torque
      "StarmobileParalyzeTarget",              # Combat Torque
      "StarmobileConfuseTarget",               # Magical Torque
      "StarmobilePoisonTarget",                # Noxious Torque
      "StarmobileSleepTarget",                 # Wicked Torque
      "TerapagosCategoryDependsOnHigherDamage" # Tera Starstorm
    )
  end
end

#===============================================================================
# Encore
#===============================================================================
# Added several Gen 9 moves to blacklist.
#-------------------------------------------------------------------------------
class Battle::Move::DisableTargetUsingDifferentMove < Battle::Move
  alias paldea_initialize initialize
  def initialize(battle, move)
    paldea_initialize(battle, move)
    @moveBlacklist.push(
      "StarmobileBurnTarget",     # Blazing Torque
      "StarmobileParalyzeTarget", # Combat Torque
      "StarmobileConfuseTarget",  # Magical Torque
      "StarmobilePoisonTarget",   # Noxious Torque
      "StarmobileSleepTarget"     # Wicked Torque
    )
  end
end

#===============================================================================
# Me First
#===============================================================================
# Added several Gen 9 moves to blacklist.
#-------------------------------------------------------------------------------
class Battle::Move::UseMoveTargetIsAboutToUse < Battle::Move
  alias paldea_initialize initialize
  def initialize(battle, move)
    paldea_initialize(battle, move)
    @moveBlacklist.push(
      "StarmobileBurnTarget",     # Blazing Torque
      "StarmobileParalyzeTarget", # Combat Torque
      "StarmobileConfuseTarget",  # Magical Torque
      "StarmobilePoisonTarget",   # Noxious Torque
      "StarmobileSleepTarget"     # Wicked Torque
    )
  end
end

#===============================================================================
# Sleep Talk
#===============================================================================
# Added several Gen 9 moves to blacklist.
#-------------------------------------------------------------------------------
class Battle::Move::UseRandomUserMoveIfAsleep < Battle::Move
  alias paldea_initialize initialize
  def initialize(battle, move)
    paldea_initialize(battle, move)
    @moveBlacklist.push(
      "StarmobileBurnTarget",     # Blazing Torque
      "StarmobileParalyzeTarget", # Combat Torque
      "StarmobileConfuseTarget",  # Magical Torque
      "StarmobilePoisonTarget",   # Noxious Torque
      "StarmobileSleepTarget"     # Wicked Torque
    )
  end
end

#===============================================================================
# Instruct
#===============================================================================
# Added several Gen 9 moves to blacklist.
#-------------------------------------------------------------------------------
class Battle::Move::TargetUsesItsLastUsedMoveAgain < Battle::Move
  alias paldea_initialize initialize
  def initialize(battle, move)
    paldea_initialize(battle, move)
    @moveBlacklist.push(
      "StarmobileBurnTarget",     # Blazing Torque
      "StarmobileParalyzeTarget", # Combat Torque
      "StarmobileConfuseTarget",  # Magical Torque
      "StarmobilePoisonTarget",   # Noxious Torque
      "StarmobileSleepTarget"     # Wicked Torque
    )
  end
end

#===============================================================================
# Thief, Covet
#===============================================================================
# Records thieved item to user's stolen item data.
#-------------------------------------------------------------------------------
class Battle::Move::UserTakesTargetItem < Battle::Move
  def pbEffectAfterAllHits(user, target)
    return if user.wild?
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || user.item
    return if target.unlosableItem?(target.item)
    return if user.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    user.setStolenItem(target.item_id, target)
    user.item = target.item
    if target.wild? && !user.initialItem && target.item == target.initialItem
      user.setInitialItem(target.item)
      target.pbRemoveItem
    else
      target.pbRemoveItem(false)
    end
    @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!", user.pbThis, target.pbThis(true), itemName))
    user.pbHeldItemTriggerCheck
  end
end

#===============================================================================
# Bestow
#===============================================================================
# Records bestowed item to target's stolen item data.
#-------------------------------------------------------------------------------
class Battle::Move::TargetTakesUserItem < Battle::Move
  def pbEffectAgainstTarget(user, target)
    itemName = user.itemName
    target.setStolenItem(user.item_id, user)
    target.item = user.item
    if user.wild? && !target.initialItem && user.item == user.initialItem
      target.setInitialItem(user.item)
      user.pbRemoveItem
    else
      user.pbRemoveItem(false)
    end
    @battle.pbDisplay(_INTL("{1} received {2} from {3}!", target.pbThis, itemName, user.pbThis(true)))
    target.pbHeldItemTriggerCheck
  end
end

#===============================================================================
# Trick, Switcheroo
#===============================================================================
# Records swapped items to user and target's stolen item data.
#-------------------------------------------------------------------------------
class Battle::Move::UserTargetSwapItems < Battle::Move
  def pbEffectAgainstTarget(user, target)
    oldUserItem = user.item
    oldUserItemName = user.itemName
    oldTargetItem = target.item
    oldTargetItemName = target.itemName
    user.setStolenItem(oldTargetItem, target)
    user.item                             = oldTargetItem
    user.effects[PBEffects::ChoiceBand]   = nil if !user.hasActiveAbility?(:GORILLATACTICS)
    user.effects[PBEffects::Unburden]     = (!user.item && oldUserItem) if user.hasActiveAbility?(:UNBURDEN)
    target.setStolenItem(oldUserItem, user)
    target.item                           = oldUserItem
    target.effects[PBEffects::ChoiceBand] = nil if !target.hasActiveAbility?(:GORILLATACTICS)
    target.effects[PBEffects::Unburden]   = (!target.item && oldTargetItem) if target.hasActiveAbility?(:UNBURDEN)
    if target.wild? && !user.initialItem && oldTargetItem == target.initialItem
      user.setInitialItem(oldTargetItem)
    end
    @battle.pbDisplay(_INTL("{1} switched items with its opponent!", user.pbThis))
    @battle.pbDisplay(_INTL("{1} obtained {2}.", user.pbThis, oldTargetItemName)) if oldTargetItem
    @battle.pbDisplay(_INTL("{1} obtained {2}.", target.pbThis, oldUserItemName)) if oldUserItem
    user.pbHeldItemTriggerCheck
    target.pbHeldItemTriggerCheck
  end
end

#===============================================================================
# Bug Bite, Pluck
#===============================================================================
# Clears the target's initial berry as it is counted as "consumed."
#-------------------------------------------------------------------------------
class Battle::Move::UserConsumeTargetBerry < Battle::Move
  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || !target.item.is_berry? || target.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    item = target.item
    itemName = target.itemName
    user.setBelched
    target.pbRemoveItem
    if target.initialItem == item
      @battle.initialItems[target.index & 1][target.pokemonIndex] = nil
    end
    @battle.pbDisplay(_INTL("{1} stole and ate its target's {2}!", user.pbThis, itemName))
    user.pbHeldItemTriggerCheck(item.id, false)
    user.pbSymbiosis
  end
end