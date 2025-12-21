################################################################################
# 
# GameData::Species changes.
# 
################################################################################


module GameData
  class Species
    #---------------------------------------------------------------------------
    # Aliased so that moves can be set as learnable at Lvl -1.
    # This is used for Move Reminder-exclusive moves.
    #---------------------------------------------------------------------------
    Species.singleton_class.alias_method :paldea_schema, :schema
    def self.schema(compiling_forms = false)
      ret = self.paldea_schema(compiling_forms)
      ret["Moves"] = [:moves, "*ie", nil, :Move]
      return ret
    end
	
    #---------------------------------------------------------------------------
    # Aliased so that Incense is no longer required for hatching baby Pokemon.
    #---------------------------------------------------------------------------
    alias paldea_get_baby_species get_baby_species
    def get_baby_species(*args)
      if Settings::MECHANICS_GENERATION >= 9
        return paldea_get_baby_species(false, nil, nil)
      end
      return paldea_get_baby_species(*args)
    end
  end
end


################################################################################
# 
# Pokemon class additions.
# 
################################################################################


class Pokemon
  alias paldea_initialize initialize
  def initialize(species, level, owner = $player, withMoves = true, recheck_form = true)
    paldea_initialize(species, level, owner, withMoves, recheck_form)
    @evo_move_count   = {}
    @evo_crest_count  = {}
    @evo_recoil_count = 0
    @evo_step_count   = 0
    if @species == :BASCULEGION && recheck_form
      f = MultipleForms.call("getFormOnCreation", self)
      if f
        self.form = f
        reset_moves if withMoves
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Move count evolution utilities.
  #-----------------------------------------------------------------------------
  def init_evo_move_count(move)
    @evo_move_count = Hash.new if !@evo_move_count
    @evo_move_count[move] = 0 if !@evo_move_count[move]
  end
  
  def move_count_evolution(move, qty = 1)
    species_data.get_evolutions.each do |evo|
      if evo[1] == :LevelUseMoveCount && evo[2] == move
        init_evo_move_count(move)
        @evo_move_count[move] += qty
        break
      end
    end
  end
  
  def evo_move_count(move)
    init_evo_move_count(move)
    return @evo_move_count[move]
  end
  
  def set_evo_move_count(move, value)
    init_evo_move_count(move)
    @evo_move_count[move] = value
  end
  
  #-----------------------------------------------------------------------------
  # Leader's crest evolution utilities.
  #-----------------------------------------------------------------------------
  def init_evo_crest_count(item)
    @evo_crest_count = Hash.new if !@evo_crest_count
    @evo_crest_count[item] = 0 if !@evo_crest_count[item]
  end
  
  def leaders_crest_evolution(item, qty = 1)
    species_data.get_evolutions.each do |evo|
      if evo[1] == :LevelDefeatItsKindWithItem && evo[2] == item
        init_evo_crest_count(item)
        @evo_crest_count[item] += qty
        break
      end
    end
  end
  
  def evo_crest_count(item)
    init_evo_crest_count(item)
    return @evo_crest_count[item]
  end
  
  def set_evo_crest_count(item, value)
    init_evo_crest_count(item)
    @evo_crest_count[item] = value
  end
  
  #-----------------------------------------------------------------------------
  # Recoil damage evolution utilities.
  #-----------------------------------------------------------------------------
  def recoil_evolution(qty = 1)
    species_data.get_evolutions.each do |evo|
      if evo[1] == :LevelRecoilDamage
        @evo_recoil_count = 0 if !@evo_recoil_count
        @evo_recoil_count += qty
        break
      end
    end
  end
  
  def evo_recoil_count
    return @evo_recoil_count || 0
  end
  
  def evo_recoil_count=(value)
    @evo_recoil_count = value
  end
  
  #-----------------------------------------------------------------------------
  # Walking evolution utilities.
  #-----------------------------------------------------------------------------
  def walking_evolution(qty = 1)
    species_data.get_evolutions.each do |evo|
      if evo[1] == :LevelWalk
        @evo_step_count = 0 if !@evo_step_count
        @evo_step_count += qty
        break
      end
    end
  end
    
  def evo_step_count
    return @evo_step_count || 0
  end
  
  def evo_step_count=(value)
    @evo_step_count = value
  end
  
  #-----------------------------------------------------------------------------
  # Edited for Move Relearner-exclusive moves.
  #-----------------------------------------------------------------------------
  def reset_moves
    this_level = self.level
    moveset = self.getMoveList
    knowable_moves = []
    moveset.each { |m| knowable_moves.push(m[1]) if (0..this_level).include?(m[0]) }
    knowable_moves = knowable_moves.reverse
    knowable_moves |= []
    knowable_moves = knowable_moves.reverse
    @moves.clear
    first_move_index = knowable_moves.length - MAX_MOVES
    first_move_index = 0 if first_move_index < 0
    (first_move_index...knowable_moves.length).each do |i|
      @moves.push(Pokemon::Move.new(knowable_moves[i]))
    end
  end
end


################################################################################
# 
# New evolution methods.
# 
################################################################################


GameData::Evolution.register({
  :id            => :CollectItems,
  :parameter     => :Item,
  :any_level_up  => true,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next $bag.quantity(parameter) >= 999
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || $bag.quantity(parameter) < 999
    $bag.remove(parameter, 999)
    next true
  }
})

GameData::Evolution.register({
  :id            => :LevelWithPartner,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && $PokemonGlobal.partner
  }
})

GameData::Evolution.register({
  :id            => :LevelUseMoveCount,
  :parameter     => :Move,
  :any_level_up  => true,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.evo_move_count(parameter) >= 20
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || pkmn.evo_move_count(parameter) < 20
    pkmn.set_evo_move_count(parameter, 0)
    next true
  }
})

GameData::Evolution.register({
  :id            => :LevelDefeatItsKindWithItem,
  :parameter     => :Item,
  :any_level_up  => true,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.evo_crest_count(parameter) >= 3
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || pkmn.evo_crest_count(parameter) < 3
    pkmn.set_evo_crest_count(parameter,0)
    next true
  }
})

GameData::Evolution.register({
  :id            => :LevelRecoilDamage,
  :parameter     => Integer,
  :any_level_up  => true,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.evo_recoil_count >= parameter
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || pkmn.evo_recoil_count < parameter
    pkmn.evo_recoil_count = 0
    next true
  }
})

GameData::Evolution.register({
  :id            => :LevelWalk,
  :parameter     => Integer,
  :any_level_up  => true,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.evo_step_count >= parameter
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || pkmn.evo_step_count < parameter
    pkmn.evo_step_count = 0
    next true
  }
})


################################################################################
# 
# Step-based event handlers.
# 
################################################################################


#-------------------------------------------------------------------------------
# Tracks steps taken to trigger walking evolutions for the lead Pokemon.
#-------------------------------------------------------------------------------
EventHandlers.add(:on_player_step_taken, :evolution_steps, proc {
  $player.first_able_pokemon.walking_evolution if $player.party.length > 0 && $player.first_able_pokemon
})

#-------------------------------------------------------------------------------
# Initializes Mirror Herb step counter.
#-------------------------------------------------------------------------------
class PokemonGlobalMetadata
  attr_accessor :mirrorherb_steps
  alias paldea_initialize initialize
  def initialize
    @mirrorherb_steps = 0
    paldea_initialize
  end
end

#-------------------------------------------------------------------------------
# Tracks steps taken while Pokemon in the party are holding a Mirror Herb.
# Every 256 steps, inherits Egg moves from other party members if possible.
#-------------------------------------------------------------------------------
EventHandlers.add(:on_player_step_taken, :mirrorherb_step, proc {
  if $player.able_party.any? { |p| p&.hasItem?(:MIRRORHERB) }
    $PokemonGlobal.mirrorherb_steps = 0 if !$PokemonGlobal.mirrorherb_steps
    $PokemonGlobal.mirrorherb_steps += 1
    if $PokemonGlobal.mirrorherb_steps > 255
      found_eggMove = false
      $player.able_party.each_with_index do |pkmn, i|
        next if pkmn.item != :MIRRORHERB
        next if pkmn.numMoves == Pokemon::MAX_MOVES
        baby_species = pkmn.species_data.get_baby_species
        eggmoves = GameData::Species.get(baby_species).egg_moves.clone
        eggmoves.shuffle.each do |move|
          next if pkmn.hasMove?(move)
          next if !$player.get_pokemon_with_move(move)
          pkmn.learn_move(move)
          found_eggMove = true
          break
        end
        break if found_eggMove
      end
      $PokemonGlobal.mirrorherb_steps = 0
    end
  else
    $PokemonGlobal.mirrorherb_steps = 0
  end
})

################################################################################
# 
# Edits to Egg generation for Tauros regional form inheritence.
# 
################################################################################

class DayCare
  module EggGenerator
    module_function
    
    def generate(mother, father)
      if mother.male? || father.female? || mother.genderless?
        mother, father = father, mother
      end
      mother_data = [mother, mother.species_data.egg_groups.include?(:Ditto)]
      father_data = [father, father.species_data.egg_groups.include?(:Ditto)]
      species_parent = (mother_data[1]) ? father : mother
      baby_species = determine_egg_species(species_parent.species, mother, father)
      mother_data.push(mother.species_data.breeding_can_produce?(baby_species))
      father_data.push(father.species_data.breeding_can_produce?(baby_species))
      egg = generate_basic_egg(baby_species, species_parent)
      inherit_form(egg, species_parent, mother_data, father_data)
      inherit_nature(egg, mother, father)
      inherit_ability(egg, mother_data, father_data)
      inherit_moves(egg, mother_data, father_data)
      inherit_IVs(egg, mother, father)
      inherit_poke_ball(egg, mother_data, father_data)
      set_shininess(egg, mother, father)
      set_pokerus(egg)
      egg.calc_stats
      return egg
    end
    
    def generate_basic_egg(species, species_parent)
      egg = Pokemon.new(species, Settings::EGG_LEVEL)
      egg.name           = _INTL("Egg")
      egg.steps_to_hatch = egg.species_data.hatch_steps
      egg.obtain_text    = _INTL("Day-Care Couple")
      egg.happiness      = 120
      egg.form           = 0 if species == :SINISTEA
      new_form = MultipleForms.call("getFormOnEggCreation", egg, species_parent)
      egg.form = new_form if new_form
      return egg
    end
  end
end

################################################################################
# 
# Form handlers.
# 
################################################################################


#-------------------------------------------------------------------------------
# Regional forms upon creating an egg.
#-------------------------------------------------------------------------------
MultipleForms.register(:RATTATA, {
  "getFormOnEggCreation" => proc { |pkmn, parent|
    if $game_map
      map_pos = $game_map.metadata&.town_map_position
      if map_pos
        form = 0
        case map_pos[0]
        #-----------------------------------------------------------------------
        when 1  # Alola region
          case pkmn.species
          when :RATTATA, :SANDSHREW, :VULPIX, :DIGLETT, :MEOWTH, :GEODUDE, :GRIMER
            form = 1
          end
        #-----------------------------------------------------------------------
        when 2  # Galar region
          case pkmn.species
          when :PONYTA, :SLOWPOKE, :FARFETCHD, :ARTICUNO, :ZAPDOS, :MOLTRES, :CORSOLA, :ZIGZAGOON, :YAMASK, :STUNFISK
            form = 1
          when :MEOWTH, :DARUMAKA
            form = 2
          end
        #-----------------------------------------------------------------------
        when 3  # Hisui region
          case pkmn.species
          when :GROWLITHE, :VOLTORB, :QWILFISH, :SNEASEL, :ZORUA
            form = 1
          end
        #-----------------------------------------------------------------------
        when 4  # Paldea region
          case pkmn.species
          when :WOOPER
            form = 1
          when :TAUROS
            form = (parent.form == 0) ? 1 : parent.form
          end
        end
        next form if form > 0 && GameData::Species.get_species_form(pkmn.species, form).form == form
      end
    end
    next 0
  }
})

MultipleForms.copy(:RATTATA, :SANDSHREW, :VULPIX, :DIGLETT, :MEOWTH, :GEODUDE, :GRIMER,      # Alolan
                   :PONYTA, :FARFETCHD, :CORSOLA, :ZIGZAGOON, :YAMASK, :STUNFISK,            # Galarian                                   
                   :SLOWPOKE, :ARTICUNO, :ZAPDOS, :MOLTRES,                                  # Galarian (DLC)
                   :GROWLITHE, :VOLTORB, :QWILFISH, :SNEASEL, :ZORUA,                        # Hisuian
                   :TAUROS, :WOOPER                                                          # Paldean
                  )                                             

#-------------------------------------------------------------------------------
# Species with regional evolutions (Hisuian forms).
#-------------------------------------------------------------------------------              
MultipleForms.register(:QUILAVA, {
  "getForm" => proc { |pkmn|
    next if pkmn.form_simple >= 2
    if $game_map
      map_pos = $game_map.metadata&.town_map_position
      next 1 if map_pos && map_pos[0] == 3   # Hisui region
    end
    next 0
  }
})

MultipleForms.copy(:QUILAVA, :DEWOTT, :DARTRIX, :PETILIL, :RUFFLET, :GOOMY, :BERGMITE)

#-------------------------------------------------------------------------------
# Dundunsparce - Segment sizes.
#-------------------------------------------------------------------------------
MultipleForms.register(:DUNSPARCE, {
  "getFormOnCreation" => proc { |pkmn|
    next (pkmn.personalID % 100 == 0) ? 1 : 0
  }
})

MultipleForms.copy(:DUNSPARCE, :DUDUNSPARCE)

#-------------------------------------------------------------------------------
# Dialga - Origin Forme.
#-------------------------------------------------------------------------------
MultipleForms.register(:DIALGA, {
  "getForm" => proc { |pkmn|
    next 1 if pkmn.hasItem?(:ADAMANTCRYSTAL)
    next 0
  }
})

#-------------------------------------------------------------------------------
# Palkia - Origin Forme.
#-------------------------------------------------------------------------------
MultipleForms.register(:PALKIA, {
  "getForm" => proc { |pkmn|
    next 1 if pkmn.hasItem?(:LUSTROUSGLOBE)
    next 0
  }
})

#-------------------------------------------------------------------------------
# Giratina - Origin Forme.
#-------------------------------------------------------------------------------
MultipleForms.register(:GIRATINA, {
  "getForm" => proc { |pkmn|
    next 1 if pkmn.hasItem?(:GRISEOUSCORE)
    next 1 if Settings::MECHANICS_GENERATION < 9 && pkmn.hasItem?(:GRISEOUSORB)
    if $game_map &&
       GameData::MapMetadata.try_get($game_map.map_id)&.has_flag?("DistortionWorld")
      next 1
    end
    next 0
  }
})

#-------------------------------------------------------------------------------
# Shaymin - Sky Forme.
#-------------------------------------------------------------------------------
MultipleForms.register(:SHAYMIN, {
  "getForm" => proc { |pkmn|
    next 0 if pkmn.fainted? || [:FROZEN, :FROSTBITE].include?(pkmn.status) || PBDayNight.isNight?
  }
})

#-------------------------------------------------------------------------------
# Hoopa - Unbound form.
#-------------------------------------------------------------------------------
MultipleForms.register(:HOOPA, {
  "getForm" => proc { |pkmn|
    if Settings::MECHANICS_GENERATION < 9 && (!pkmn.time_form_set ||
       pbGetTimeNow.to_i > pkmn.time_form_set.to_i + (60 * 60 * 24 * 3))   # 3 days
      next 0
    end
  },
  "onSetForm" => proc { |pkmn, form, oldForm|
    pkmn.time_form_set = (form > 0) ? pbGetTimeNow.to_i : nil if Settings::MECHANICS_GENERATION < 9
    # Move Change
    form_moves = [
      :HYPERSPACEHOLE,    # Confined form
      :HYPERSPACEFURY,    # Unbound form
    ]
    # Find a known move that should be forgotten
    old_move_index = -1
    pkmn.moves.each_with_index do |move, i|
      next if !form_moves.include?(move.id)
      old_move_index = i
      break
    end
    # Determine which new move to learn (if any)
    new_move_id = form_moves[form]
    new_move_id = nil if !GameData::Move.exists?(new_move_id)
    new_move_id = nil if pkmn.hasMove?(new_move_id)
    # Forget a known move (if relevant) and learn a new move (if relevant)
    if old_move_index >= 0
      old_move_name = pkmn.moves[old_move_index].name
      if new_move_id.nil?
        # Just forget the old move
        pkmn.forget_move_at_index(old_move_index)
      else
        # Replace the old move with the new move (keeps the same index)
        pkmn.moves[old_move_index].id = new_move_id
        new_move_name = pkmn.moves[old_move_index].name
        pbMessage("\\se[]" + _INTL("{1} learned {2}!", pkmn.name, new_move_name) + "\\se[Pkmn move learnt]")
      end
    end
  }
})

#-------------------------------------------------------------------------------
# Basculegion - Gender forms.
#-------------------------------------------------------------------------------
MultipleForms.register(:BASCULEGION, {
  "getForm" => proc { |pkmn|
    next pkmn.gender
  },
  "getFormOnCreation" => proc { |pkmn|
    next pkmn.gender
  }
})

#-------------------------------------------------------------------------------
# Oinkologne - Gender forms.
#-------------------------------------------------------------------------------
MultipleForms.register(:LECHONK, {
  "getForm" => proc { |pkmn|
    next pkmn.gender
  },
  "getFormOnCreation" => proc { |pkmn|
    next pkmn.gender
  }
})

MultipleForms.copy(:LECHONK, :OINKOLOGNE)

#-------------------------------------------------------------------------------
# Maushold - Family sizes.
#-------------------------------------------------------------------------------
MultipleForms.register(:TANDEMAUS, {
  "getFormOnCreation" => proc { |pkmn|
    next (pkmn.personalID % 100 == 0) ? 1 : 0
  }
})

MultipleForms.copy(:TANDEMAUS, :MAUSHOLD)

#-------------------------------------------------------------------------------
# Squawkabilly - Plumage colors.
#-------------------------------------------------------------------------------
MultipleForms.register(:SQUAWKABILLY, {
  "getFormOnCreation" => proc { |pkmn|
    next rand(4)
  }
})

#-------------------------------------------------------------------------------
# Palafin - Zero Form.
#-------------------------------------------------------------------------------
MultipleForms.register(:PALAFIN, {
  "getFormOnLeavingBattle" => proc { |pkmn, battle, usedInBattle, endBattle|
    next 0 if endBattle
  }
})

#-------------------------------------------------------------------------------
# Tatsugiri - Multiple Forms.
#-------------------------------------------------------------------------------
MultipleForms.register(:TATSUGIRI, {
  "getFormOnCreation" => proc { |pkmn|
    next rand(3)
  }
})

#-------------------------------------------------------------------------------
# Poltchageist/Sinistcha - Unremarkable/Masterpiece forms.
#-------------------------------------------------------------------------------
MultipleForms.copy(:SINISTEA, :POLTEAGEIST, :POLTCHAGEIST, :SINISTCHA)

#-------------------------------------------------------------------------------
# Ogerpon - Masked forms.
#-------------------------------------------------------------------------------
MultipleForms.register(:OGERPON, {
  "getForm" => proc { |pkmn|
    next 1 if pkmn.hasItem?(:WELLSPRINGMASK)
    next 2 if pkmn.hasItem?(:HEARTHFLAMEMASK)
    next 3 if pkmn.hasItem?(:CORNERSTONEMASK)
    next 0
  },
  "getFormOnStartingBattle" => proc { |pkmn, wild|
    next 5 if pkmn.hasItem?(:WELLSPRINGMASK)
    next 6 if pkmn.hasItem?(:HEARTHFLAMEMASK)
    next 7 if pkmn.hasItem?(:CORNERSTONEMASK)
    next 4
  },
  "getFormOnLeavingBattle" => proc { |pkmn, battle, usedInBattle, endBattle|
    next pkmn.form - 4 if pkmn.form > 3 && endBattle
  },
  "getTerastalForm" => proc { |pkmn|
    next pkmn.form + 4
  },
  "getUnTerastalForm" => proc { |pkmn|
    next pkmn.form - 4
  },
  # Compability for Pokedex Data Page plugin
  "getDataPageInfo" => proc { |pkmn|
    next if pkmn.form < 8
    mask = nil
    case pkmn.form
    when 9  then mask = :WELLSPRINGMASK
    when 10 then mask = :HEARTHFLAMEMASK
    when 11 then mask = :CORNERSTONEMASK
    end
    next [pkmn.form, pkmn.form - 4, mask]
  }
})

#-------------------------------------------------------------------------------
# Terapagos - Terastal and Stellar form.
#-------------------------------------------------------------------------------
MultipleForms.register(:TERAPAGOS, {
  "getFormOnLeavingBattle" => proc { |pkmn, battle, usedInBattle, endBattle|
    next 0 if pkmn.form > 0 && endBattle
  },
  "getTerastalForm" => proc { |pkmn|
    next 2
  },
  "getUnTerastalForm" => proc { |pkmn|
    next 1
  },
  "getDataPageInfo" => proc { |pkmn|
    next if pkmn.form < 2
    next [pkmn.form, 1]
  }
})

# Zygarde - Mega Zygarde form.
#-------------------------------------------------------------------------------
MultipleForms.register(:ZYGARDE, {
  "changePokemonOnMegaEvolve" => proc { |battler, battle|
    if GameData::Move.exists?(:NIHILLIGHT)
      if [4, 5].include?(battler.form)
        battler.eachMoveWithIndex do |m, i|
          next if m.id != :COREENFORCER
          pokemon_move = battler.pokemon.moves[i]
          pokemon_move.id = :NIHILLIGHT
          battler_move = Battle::Move.from_pokemon_move(battle, pokemon_move)
          battler.moves[i] = battler_move
          if battle.choices[battler.index][1] == i
            battle.choices[battler.index][2] = battler_move 
            battle.pbDisplay(_INTL("{1}'s {2} transform into {3}!", battler.pbThis,
                              GameData::Move.get(:COREENFORCER).name, 
                              GameData::Move.get(:NIHILLIGHT).name
                            ))
            break
          end
        end
      end
    end
  },
  "getMegaMoves" => proc { |pkmn|
    next { :COREENFORCER => :NIHILLIGHT }
  },
  "changePokemonOnLeavingBattle" => proc { |pkmn, battle, usedInBattle, endBattle|
    if GameData::Move.exists?(:COREENFORCER) && endBattle
      pkmn.moves.each { |move| move.id = :COREENFORCER if move.id == :NIHILLIGHT }
    end
  }
})