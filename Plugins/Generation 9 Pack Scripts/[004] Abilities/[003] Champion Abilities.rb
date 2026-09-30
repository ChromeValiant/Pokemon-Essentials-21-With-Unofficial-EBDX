################################################################################
# 
# Champion ability handlers.
# 
################################################################################
# UPDATED
################################################################################

#===============================================================================
# Healer
#===============================================================================
Battle::AbilityEffects::EndOfRoundHealing.add(:HEALER,
  proc { |ability, battler, battle|
    chance = Settings::CHAMPIONS_MECHANICS ? 50 : 30
    next if battle.pbRandom(100) >= chance
    battler.allAllies.each do |b|
      next if b.status == :NONE
      battle.pbShowAbilitySplash(battler)
      oldStatus = b.status
      b.pbCureStatus(Battle::Scene::USE_ABILITY_SPLASH)
      if !Battle::Scene::USE_ABILITY_SPLASH
        case oldStatus
        when :SLEEP
          battle.pbDisplay(_INTL("{1}'s {2} woke its partner up!", battler.pbThis, battler.abilityName))
        when :POISON
          battle.pbDisplay(_INTL("{1}'s {2} cured its partner's poison!", battler.pbThis, battler.abilityName))
        when :BURN
          battle.pbDisplay(_INTL("{1}'s {2} healed its partner's burn!", battler.pbThis, battler.abilityName))
        when :PARALYSIS
          battle.pbDisplay(_INTL("{1}'s {2} cured its partner's paralysis!", battler.pbThis, battler.abilityName))
        when :FROZEN
          battle.pbDisplay(_INTL("{1}'s {2} defrosted its partner!", battler.pbThis, battler.abilityName))
        end
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

#===============================================================================
# Unseen Fist
#===============================================================================
Battle::AbilityEffects::DamageCalcFromUser.add(:UNSEENFIST,
  proc { |ability, user, target, move, mults, power, type|
    if Settings::CHAMPIONS_MECHANICS
      if  target.effects[PBEffects::BurningBulwark]         ||
          target.effects[PBEffects::BanefulBunker]          ||
          target.effects[PBEffects::KingsShield]            ||
          target.effects[PBEffects::Obstruct]               ||
          target.effects[PBEffects::Protect]                ||
          target.effects[PBEffects::SpikyShield]            ||
          target.pbOwnSide.effects[PBEffects::CraftyShield] ||
          target.pbOwnSide.effects[PBEffects::MatBlock]     ||
          target.pbOwnSide.effects[PBEffects::QuickGuard]   ||
          target.pbOwnSide.effects[PBEffects::WideGuard]
        mults[:final_damage_multiplier] *= 0.25 if move.pbContactMove?(user)
      end
    end
  }
)

Battle::AbilityEffects::OnDealingHit.add(:UNSEENFIST,
  proc { |ability, user, target, move, battle|
    next if !Settings::CHAMPIONS_MECHANICS
    next if !move.pbContactMove?(user)
    next if !target.effects[PBEffects::BurningBulwark]         &&
            !target.effects[PBEffects::BanefulBunker]          &&
            !target.effects[PBEffects::KingsShield]            &&
            !target.effects[PBEffects::Obstruct]               &&
            !target.effects[PBEffects::Protect]                &&
            !target.effects[PBEffects::SpikyShield]            &&
            !target.pbOwnSide.effects[PBEffects::CraftyShield] &&
            !target.pbOwnSide.effects[PBEffects::MatBlock]     &&
            !target.pbOwnSide.effects[PBEffects::QuickGuard]   &&
            !target.pbOwnSide.effects[PBEffects::WideGuard]
    battle.pbShowAbilitySplash(user)
    battle.pbDisplay(_INTL("The opposing {1} couldn't fully protect itself and got hurt!", target.pbThis))
    battle.pbHideAbilitySplash(user)
  }
)

#===============================================================================
# Sand Veil
#===============================================================================
# Battle::AbilityEffects::AccuracyCalcFromTarget.add(:SANDVEIL,
#   proc { |ability, mods, user, target, move, type|
#     mods[:evasion_multiplier] *= 1.25 if target.effectiveWeather == :Sandstorm && !user.hasActiveAbility?(:MEGASOL)
#   }
# )

#===============================================================================
# Snow Cloak
#===============================================================================
# Battle::AbilityEffects::AccuracyCalcFromTarget.add(:SNOWCLOAK,
#   proc { |ability, mods, user, target, move, type|
#     mods[:evasion_multiplier] *= 1.25 if target.effectiveWeather == :Hail && !user.hasActiveAbility?(:MEGASOL)
#   }
# )
################################################################################
# NEW ABILITIES
################################################################################
#===============================================================================
# Dragonize 
#===============================================================================
Battle::AbilityEffects::ModifyMoveBaseType.add(:DRAGONIZE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:DRAGON)
    move.powerBoost = true
    next :DRAGON
  }
)

Battle::AbilityEffects::DamageCalcFromUser.copy(:AERILATE, :DRAGONIZE)

#===============================================================================
# Mega Sol (Added to all sun-related moves)
#===============================================================================

#===============================================================================
# Piercing Drill
#===============================================================================
Battle::AbilityEffects::DamageCalcFromUser.copy(:UNSEENFIST, :PIERCINGDRILL)
Battle::AbilityEffects::OnDealingHit.copy(:UNSEENFIST, :PIERCINGDRILL)

#===============================================================================
# Spicy Spray
#===============================================================================
Battle::AbilityEffects::OnBeingHit.add(:SPICYSPRAY,
  proc { |ability, user, target, move, battle|
    next if !move.pbDamagingMove?
    next if user.burned?
    battle.pbShowAbilitySplash(target)
    if user.pbCanBurn?(target, Battle::Scene::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      msg = nil
      if !Battle::Scene::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} burned {3}!", target.pbThis, target.abilityName, user.pbThis(true))
      end
      user.pbBurn(target, msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

#===============================================================================
# Fire Mane
#===============================================================================
Battle::AbilityEffects::DamageCalcFromUser.add(:FIREMANE,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] *= 1.5 if type == :FIRE
  }
)

#===============================================================================
# Eelevate
#===============================================================================
Battle::AbilityEffects::OnEndOfUsingMove.add(:EELEVATE,
  proc { |ability, user, targets, move, battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0
    userStats = user.plainStats
    highestStatValue = 0
    userStats.each_value { |value| highestStatValue = value if highestStatValue < value }
    GameData::Stat.each_main_battle do |s|
      next if userStats[s.id] < highestStatValue
      if user.pbCanRaiseStatStage?(s.id, user)
        user.pbRaiseStatStageByAbility(s.id, numFainted, user)
      end
      break
    end
  }
)