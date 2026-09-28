class Battle
  def pbGenerateAllyBattler(species, level)
    if pbSideSize(1) == 1
      self.setBattleMode("2v2")
      pokemon = pbGenerateWildPokemon(species, level)
      pokemon.shiny = false;
      pokemon.ability_index = 0;
      pbCreateBattler(3,pokemon,@party2.length)
      @party2.push(pokemon)
      @party2order.push(@party2order.length)
      @abils_triggered[@battlers[3].index & 1].push(@battlers[3].pokemonIndex)
      @rage_hit_count[@battlers[3].index & 1].push(@battlers[3].pokemonIndex)
      @battleAI.create_ai_objects
    else
      pokemon = pbGenerateWildPokemon(species, level)
      pokemon.shiny = false;
      pokemon.abilityindex = 0;
      @battlers[3].pbInitialize(pokemon,@party2.length)
    end
    @scene.pbSOSJoin(3,pokemon)
  end
end

class Battle::Scene
  def pbSOSJoin(battlerindex,pkmn)


    @sprites["pokemon#{battlerindex}"] = DynamicPokemonSprite.new(battlerindex, @viewport, @battle)
    @sprites["pokemon#{battlerindex}"].z = @sprites["battlebg"].battler(battlerindex).z
    @sprites["pokemon#{battlerindex}"].index = battlerindex
    @sprites["pokemon#{battlerindex}"].setPokemonBitmap(pkmn, false)
    @sprites["pokemon#{battlerindex}"].tone = Tone.new(-255, -255, -255, -255)
    @sprites["pokemon#{battlerindex}"].opacity = 0
    if @sprites["dataBox#{battlerindex}"].nil?
      @sprites["dataBox#{battlerindex}"] = DataBoxEBDX.new(@battle.battlers[battlerindex], @msgview, @battle.pbPlayer, self)
      @sprites["dataBox#{battlerindex}"].render
    else
      @sprites["dataBox#{battlerindex}"].render
    end
    pkmn = @battle.battlers[battlerindex].effects[PBEffects::Illusion] || pkmn
    pbChangePokemon(battlerindex,pkmn)
    @sprites["battlebg"].adjustMetrics
    pbRefresh

    EliteBattle.playCommonAnimation(:APPEAR, self, 3)
      @sprites["dataBox#{battlerindex}"].appear
  end
end