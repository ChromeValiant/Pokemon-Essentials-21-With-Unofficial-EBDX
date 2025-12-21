################################################################################
# 
# Z-A item handlers.
# 
################################################################################
#===============================================================================
# Health Mochi
#===============================================================================
ItemHandlers::UseOnPokemon.add(:CANARIBREAD, proc { |item, qty, pkmn, scene|
  next pbHPItem(pkmn, 100, scene)
})

ItemHandlers::CanUseInBattle.copy(:POTION,:CANARIBREAD)

ItemHandlers::BattleUseOnPokemon.add(:CANARIBREAD, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, 100, scene)
})