#===============================================================================
#  Elite Battle DX - SOS Helper
#  It gets to be called by a Battle Script
#===============================================================================
class Battle
  def pbGenerateAllyBattler(species, level, ability_index=0, shiny=false)
    if trainerBattle?
        self.pbDisplay(_INTL("...but nobody came!"))
        return
    end
    case pbSideSize(1)
    when 1
      if pbSideSize(0) == 1
        self.setBattleMode("1v2")
      else
        self.setBattleMode("2v2")
      end
      i = 3
      pokemon = pbGenerateWildPokemon(species, level)
      pokemon.shiny = shiny;
      pokemon.ability_index = ability_index;
      pbCreateBattler(3,pokemon,@party2.length)
      @party2.push(pokemon)
      @party2order.push(@party2order.length)
      @rage_hit_count[@battlers[3].index & 1].push(@battlers[3].pokemonIndex)
      @battleAI.create_ai_objects
    when 2 
      pokemon = pbGenerateWildPokemon(species, level)
      pokemon.shiny = shiny;
      pokemon.ability_index = ability_index;
      i = (@battlers[1].fainted?) ? 1 : (@battlers[3].fainted?) ? 3 : 5
      @battlers[i].pbInitialize(pokemon, @party2.length) if !@battlers[i].nil?
      if i == 5
        if pbSideSize(0) == 1
          self.setBattleMode("1v3")
        elsif pbSideSize(0) == 2
          self.setBattleMode("2v3")
        else
          self.setBattleMode("3v3")
        end
        pbCreateBattler(5,pokemon,@party2.length)
        @party2.push(pokemon)
        @party2order.push(@party2order.length)
        @rage_hit_count[@battlers[5].index & 1].push(@battlers[5].pokemonIndex)
        @battleAI.create_ai_objects
      else
        @party2[i] = pokemon
      end
    when 3
      i = (@battlers[1].fainted?) ? 1 : (@battlers[3].fainted?) ? 3 : 5
      if !@battlers[i].fainted?
        self.pbDisplay(_INTL("...but nobody came!"))
        return
      end
      pokemon = pbGenerateWildPokemon(species, level)
      pokemon.shiny = shiny;
      pokemon.ability_index = ability_index;
      @battlers[i].pbInitialize(pokemon, @party2.length) if !@battlers[i].nil?
    end
    pbSetAbilityTrigger(@battlers[i], false)
    @scene.pbSOSJoin(i,pokemon)
    @battlers[i].pbTriggerAbilityOnGainingIt
  end
end
#===============================================================================
# Class to correctly add a new battler to the battle scene
#===============================================================================
class Battle::Scene
  def pbSOSJoin(battlerindex,pkmn)
    @sprites["pokemon_#{battlerindex}"] = DynamicPokemonSprite.new(@battle.doublebattle?,battlerindex, @viewport, @battle)
    @sprites["pokemon_#{battlerindex}"].z = @sprites["battlebg"].battler(battlerindex).z
    @sprites["pokemon_#{battlerindex}"].index = battlerindex
    @sprites["pokemon_#{battlerindex}"].setPokemonBitmap(pkmn, false)
    @sprites["pokemon_#{battlerindex}"].tone = Tone.new(-255, -255, -255, -255)
    @sprites["pokemon_#{battlerindex}"].opacity = 0
    if !@sprites["dataBox_#{battlerindex}"].nil?
      @sprites["dataBox_#{battlerindex}"].dispose
    end
    @sprites["dataBox_#{battlerindex}"] = DataBoxEBDX.new(@battle.battlers[battlerindex], @msgview, @battle.pbPlayer, self)
    @sprites["dataBox_#{battlerindex}"].render
    pkmn = @battle.battlers[battlerindex].effects[PBEffects::Illusion] || pkmn
    pbChangePokemon(battlerindex,pkmn)
    @sprites["battlebg"].adjustMetrics
    pbRefresh

    EliteBattle.playCommonAnimation(:APPEAR, self, battlerindex)
    @sprites["dataBox_#{battlerindex}"].appear
    pbShowAllDataboxes
  end
end