#===============================================================================
# Battle
#===============================================================================
class Battle
  attr_reader :stolenItems, :caughtPartyIndicies
  
  #-----------------------------------------------------------------------------
  # Aliased to initialize data for tracking items stolen during battle.
  #-----------------------------------------------------------------------------
  alias stolen_init initialize
  def initialize(*args)
    stolen_init(*args)
    @stolenItems = [Array.new(@party1.length, []), Array.new(@party2.length, [])]
    @caughtPartyIndicies = []
  end
end

#===============================================================================
# Battle::Battler
#===============================================================================
class Battle::Battler
  #-----------------------------------------------------------------------------
  # Updates data tracking the current item stolen by the battler.
  # [item] is the ID of the item being stolen.
  # [owner] is the battler who originally held the [item], or nil.
  #-----------------------------------------------------------------------------
  def setStolenItem(item, owner = nil)
    return if !Settings::RESTORE_ITEMS_AFTER_BATTLE
    return if !@battle.wildBattle?
    return if item.nil?
    item = item.id if item.is_a?(GameData::Item)
    if owner
      stolenData = [item, owner.idxOwnSide, owner.pokemonIndex]
    else
      stolenData = [item, self.idxOpposingSide, nil]
    end
    @battle.stolenItems[@index & 1][@pokemonIndex] = stolenData
  end
  
  #-----------------------------------------------------------------------------
  # Returns a battler's stolen item data.
  #-----------------------------------------------------------------------------
  def stolenItemData
    return @battle.stolenItems[@index & 1][@pokemonIndex]
  end
  
  #-----------------------------------------------------------------------------
  # Aliased to record the party index of a captured Pokemon so initial items can be set.
  #-----------------------------------------------------------------------------
  alias stolen_pbReset pbReset
  def pbReset
    @battle.caughtPartyIndicies.push(@pokemonIndex)
    stolen_pbReset
  end
  
  #-----------------------------------------------------------------------------
  # Aliased to ignore resetting initial items when setting enabled.
  #-----------------------------------------------------------------------------
  alias stolen_setInitialItem setInitialItem
  def setInitialItem(value)
    return if Settings::RESTORE_ITEMS_AFTER_BATTLE
    stolen_setInitialItem(value)
  end
  
  #-----------------------------------------------------------------------------
  # Aliased to clear stolen item data when held item is removed.
  #-----------------------------------------------------------------------------
  alias stolen_pbRemoveItem pbRemoveItem
  def pbRemoveItem(permanent = true)
    stolen_pbRemoveItem(permanent)
    return if !@item_id.nil?
    @battle.stolenItems[@index & 1][@pokemonIndex].clear
  end
  
  #-----------------------------------------------------------------------------
  # Aliased to clear initial item if berry is consumed.
  #-----------------------------------------------------------------------------
  alias stolen_pbConsumeItem pbConsumeItem
  def pbConsumeItem(recoverable = true, symbiosis = true, belch = true)
    if Settings::RESTORE_ITEMS_AFTER_BATTLE && @battle.wildBattle?
      if @item_id && GameData::Item.get(@item_id).is_berry?
        # Clears user's initial item if initial hold item is a berry.
        if self.initialItem == @item_id
          @battle.initialItems[@index & 1][@pokemonIndex] = nil
        end
        # If berry was stolen, clear initial item on original berry holder.
        if !self.stolenItemData[2].nil?
          item, side, idxParty = *self.stolenItemData
          @battle.initialItems[side][idxParty] = nil if item == @item_id
        end
      end
    end
    stolen_pbConsumeItem(recoverable, symbiosis, belch)
  end
end

#===============================================================================
# Battle::CatchAndStoreMixin
#===============================================================================
module Battle::CatchAndStoreMixin
  #-----------------------------------------------------------------------------
  # Aliased to set initial items on both the party and any captured Pokemon.
  #-----------------------------------------------------------------------------
  alias stolen_pbRecordAndStoreCaughtPokemon pbRecordAndStoreCaughtPokemon
  def pbRecordAndStoreCaughtPokemon
    if Settings::RESTORE_ITEMS_AFTER_BATTLE && !pbInSafari?
      # Iterates through each captured Pokemon and returns its initial item.
      # Deletes the party's stolen item data of returned item so it isn't sent to the bag.
      @caughtPokemon.each_with_index do |pkmn, i|
        next if !pkmn
        idxParty = @caughtPartyIndicies[i]
        initialItem = @initialItems[1][idxParty]
        pkmn.item = initialItem
        @stolenItems[0].length.times do |i|
          data = @stolenItems[0][i]
          next if !data || data.empty?
          next if data != [initialItem, 1, idxParty]
          @stolenItems[0][i].clear
          break
        end
      end
      @caughtPartyIndicies.clear
      # Iterates through the party and returns each of their initial items.
      # Checks each party member for any stolen items and sends them to the bag, if any.
      pbParty(0).each_with_index do |pkmn, i|
        next if !pkmn
        pkmn.item = @initialItems[0][i]
        stolenData = @stolenItems[0][i]
        next if !stolenData || stolenData.empty?
        $bag.add(stolenData[0]) if stolenData[1] == 1
        @stolenItems[0][i].clear
      end
    end
    stolen_pbRecordAndStoreCaughtPokemon
  end
end