#===============================================================================
# UPDATED
#===============================================================================
# Growth
#===============================================================================
class Battle::Move::RaiseUserAtkSpAtk1Or2InSun < Battle::Move::MultiStatUpMove
  def pbOnStartUse(user, targets)
    increment = 1
    increment = 2 if [:Sun, :HarshSun].include?(user.effectiveWeather) || user.hasActiveAbility?(:MEGASOL)
    @statUp[1] = @statUp[3] = increment
  end
end

#===============================================================================
# Thunder
#===============================================================================
class Battle::Move::ParalyzeTargetAlwaysHitsInRainHitsTargetInSky < Battle::Move::ParalyzeTarget
  alias champions_pbBaseAccuracy pbBaseAccuracy
  def pbBaseAccuracy(user, target)
    return 50 if user.hasActiveAbility?(:MEGASOL)
    return champions_pbBaseAccuracy(user, target)
  end
end

#===============================================================================
# Hurricane
#===============================================================================
class Battle::Move::ConfuseTargetAlwaysHitsInRainHitsTargetInSky < Battle::Move::ConfuseTarget
  alias champions_pbBaseAccuracy pbBaseAccuracy
  def pbBaseAccuracy(user, target)
    return 50 if user.hasActiveAbility?(:MEGASOL)
    return champions_pbBaseAccuracy(user, target)
  end
end

#===============================================================================
# Weather Ball
#===============================================================================
class Battle::Move::TypeAndPowerDependOnWeather < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if user.effectiveWeather != :None || user.hasActiveAbility?(:MEGASOL)
    return baseDmg
  end

  alias champions_pbBaseType pbBaseType
  def pbBaseType(user)
    ret = champions_pbBaseType(user)
    ret = :FIRE if GameData::Type.exists?(:FIRE) && user.hasActiveAbility?(:MEGASOL)
    return ret
  end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Solar Beam, Solar Blade)
# Power halved in all weather except sunshine. In sunshine, takes 1 turn instead.
#===============================================================================
class Battle::Move::TwoTurnAttackOneTurnInSun < Battle::Move::TwoTurnMove
  def pbIsChargingTurn?(user)
    ret = super
    if !user.effects[PBEffects::TwoTurnAttack] &&
       ([:Sun, :HarshSun].include?(user.effectiveWeather) || user.hasActiveAbility?(:MEGASOL))
      @powerHerb = false
      @chargingTurn = true
      @damagingTurn = true
      return false
    end
    return ret
  end

  def pbBaseDamageMultiplier(damageMult, user, target)
    damageMult /= 2 if ![:None, :Sun, :HarshSun].include?(user.effectiveWeather) && !user.hasActiveAbility?(:MEGASOL)
    return damageMult
  end

  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} took in sunlight!", user.pbThis))
    @battle.pbShowAbilitySplash(user) if user.hasActiveAbility?(:MEGASOL)
  end

  def pbAttackingTurnMessage(user, targets)
    super
    @battle.pbHideAbilitySplash(user) if user.hasActiveAbility?(:MEGASOL)
  end
end

#===============================================================================
# Heals user by an amount depending on the weather. (Moonlight, Morning Sun,
# Synthesis)
#===============================================================================
class Battle::Move::HealUserDependingOnWeather < Battle::Move::HealingMove
  alias megasol_pbOnStartUse pbOnStartUse
  def pbOnStartUse(user, targets)
    megasol_pbOnStartUse(user, targets)
    @healAmount = (user.totalhp * 2 / 3.0).round if user.hasActiveAbility?(:MEGASOL)
    @battle.pbShowAbilitySplash(user) if user.hasActiveAbility?(:MEGASOL)
  end

  def pbEffectGeneral(user)
    @battle.pbHideAbilitySplash(user) if user.hasActiveAbility?(:MEGASOL)
    super
  end
end

#===============================================================================
# Toxic Thread
#===============================================================================
# Toggles between the Gen 9 or Champions versions of speed stat drop.
#-------------------------------------------------------------------------------
class Battle::Move::PoisonTargetLowerTargetSpeed1 < Battle::Move
  def initialize(battle, move)
    super
    qty = Settings::CHAMPIONS_MECHANICS && @id == :TOXICTHREAD ? 2 : 1
    @statDown = [:SPEED, qty]
  end
end

#===============================================================================
# Freeze-Dry
#===============================================================================
class Battle::Move::FreezeTargetSuperEffectiveAgainstWater < Battle::Move::FreezeTarget
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbFreeze if target.pbCanFreeze?(user, false, self) && !Settings::CHAMPIONS_MECHANICS
  end
end

#===============================================================================
# Knock Off
#===============================================================================
class Battle::Move::RemoveTargetItem < Battle::Move
  def pbEffectAfterAllHits(user, target)
    return if user.wild?   # Wild Pokémon can't knock off
    return if user.fainted? && !Settings::CHAMPIONS_MECHANICS
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || target.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    target.pbRemoveItem(false)
    @battle.pbDisplay(_INTL("{1} dropped its {2}!", target.pbThis, itemName))
  end
end