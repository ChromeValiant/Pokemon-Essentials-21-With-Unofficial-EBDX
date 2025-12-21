#===============================================================================
# LEGENDS Z-A NEW MOVES
#===============================================================================

#===============================================================================
# This move ignores target's Defense, Special Defense and evasion stat changes.
# This move also can hit Fairy-type. (Nihil Light)
#===============================================================================
class Battle::Move::IgnoreTargetDefSpDefEvaStatStagesHitFairyType < Battle::Move::IgnoreTargetDefSpDefEvaStatStages
  def pbCalcTypeModSingle(moveType, defType, user, target)
    return Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER if moveType == :DRAGON && defType == :FAIRY
    return super
  end
end

#===============================================================================
# LEGENDS Z-A UPDATED MOVES
#===============================================================================

#===============================================================================
# Water Shuriken
#===============================================================================
class Battle::Move::HitTwoToFiveTimesOrThreeForAshGreninja < Battle::Move::HitTwoToFiveTimes
  def multiHitMove?
    return false if user.isSpecies?(:GRENINJA) && user.form == 3 # Mega Greninja
    return super
  end

  def pbNumHits(user, targets)
    return 1 if user.isSpecies?(:GRENINJA) && user.form == 3 # Mega Greninja
    return 3 if user.isSpecies?(:GRENINJA) && user.form == 2
    return super
  end

  def pbBaseDamage(baseDmg, user, target)
    return 75 if user.isSpecies?(:GRENINJA) && user.form == 3 # Mega Greninja
    return 20 if user.isSpecies?(:GRENINJA) && user.form == 2
    return super
  end
end