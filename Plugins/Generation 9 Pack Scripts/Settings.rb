################################################################################
# 
# Settings.
# 
################################################################################


module Settings
  #=============================================================================
  # Weather Settings (Hail/Snow)
  #=============================================================================
  # 0 : Hail     (Classic) Hail weather functions as it did in Gen 8 and older.
  # 1 : Snow      (Gen 9+) Snow weather replaces Hail. Boosts Defence of Ice-types.
  # 2 : Hailstorm (Custom) Hailstorm weather combines both versions.
  #-----------------------------------------------------------------------------
  # Note: In all versions of Snow/Hail, the odds of inflicting the Frostbite 
  # status is doubled if a move is capable of inflicting Frostbite. Pokemon with
  # the Drowsy status are also twice as likely to be unable to act each turn.
  #-----------------------------------------------------------------------------
  HAIL_WEATHER_TYPE = 1
  
  
  #=============================================================================
  # Status Settings (Drowsy/Frostbite)
  #=============================================================================
  # When true, effects that would normally check for or inflict Sleep/Freeze
  # will call the Drowsy/Frostbite statuses instead. If false, they will be
  # treated as separate status conditions.
  #-----------------------------------------------------------------------------
  SLEEP_EFFECTS_CAUSE_DROWSY     = false
  FREEZE_EFFECTS_CAUSE_FROSTBITE = false
  #-----------------------------------------------------------------------------
  # When true, Sleep can be cured by getting hit from electrocute moves.
  # (Spark, Volt Tackle, and Wild Charge)
  #-----------------------------------------------------------------------------
  ELECTROCUTE_MOVES_CURE_SLEEP = false
  

  #=============================================================================
  # Hidden Power Move Settings
  #=============================================================================
  # When true, hidden move type determined similar to Judgement with Legend Plate.
  #-----------------------------------------------------------------------------
  HIDDEN_POWER_USE_PLA_MECHANICS = false
  

  #=============================================================================
  # Held Item Settings
  #=============================================================================
  # When true, the party's original held items will be restored after battle,
  # even if they were consumed or removed. Doesn't apply to consumed Berries.
  # In addition, any items stolen from or received by wild Pokemon will be
  # sent directly to the bag at the end of battle.
  #-----------------------------------------------------------------------------
  RESTORE_ITEMS_AFTER_BATTLE = true
  

  #=============================================================================
  # Mechanic Settings.
  #=============================================================================
  # Makes game mechanics function like their Gen 9 equivalents where appropriate. 
  # Don't change this setting if you want the full Gen 9 experience.
  #-----------------------------------------------------------------------------
  # Updated Effects:
  # -Battle Bond Ability now boosts stats instead of changing into Ash-Greninja.
  # -Protean/Libero Abilities now only trigger once per switch-in.
  # -Dauntless Shield/Intrepid Sword now only trigger once per battle.
  # -Ally Switch now fails with consecutive use.
  # -Charge effect now lasts until the next Electric-type move is used.
  # -Transistor ability grants a 30% power boost, down from 50%.
  # -Incense is no longer required to hatch baby species of certain Pokemon.
  #-----------------------------------------------------------------------------
  MECHANICS_GENERATION = 9
  #-----------------------------------------------------------------------------
  # When true, makes status, abilities, and moves function like in Pokemon Champions.
  #-----------------------------------------------------------------------------
  # Updated Effects:
  # -Freeze last up to 3 turns and 25% chance getting thaws.
  # -12.5% Fully Paralysis chances.
  # -Sleep last up to 2 turn, 1/3 chance to wake up at the 2nd turn.
  # -Healer ability 50% chance cures allies status condition
  # -Unseen Fist and Piercing Drill makes a quarter of damage from contact moves againts protections
  # -Unselectable Fake Out and First Impression after the first turn of the pokemon on the field
  # -additional effect of Rapid Spin and Knock Off will be triggered even if the caster faint
  # -0% chances of frozen by Freeze-Dry
  # -Toxic Thread lowers speed stat by 2 stages
  # -Salt Cure inflicted 1/16 or 1/8 (water and/or steel-type) of its maximum HP at the end of each turn
  # -Change the total PP of each moves to 8, 12, 16, or 20
  #-----------------------------------------------------------------------------
  CHAMPIONS_MECHANICS = true
end