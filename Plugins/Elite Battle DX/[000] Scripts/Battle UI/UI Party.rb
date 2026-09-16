#===============================================================================
#  Battle Party UI (EBDX Style)
#  Replicates the EBDX Bag pocket layout for Pokémon selection in battle.
#===============================================================================

class BattlePartyWindowEBDX
  attr_reader :index, :ret, :finished, :scene, :party, :items
  attr_accessor :sprites

  def initialize(scene, viewport, party)
    @scene = scene
    @battle = scene.battle
    @party = party
    @index = 0
    @oldindex = -1
    @finished = false
    @disposed = false
    @page = 0
    @item = 0
    @olditem = 0
    @back = false
    @ret = nil
    @path = "Graphics/EBDX/Pictures/Party/"
    @baseColor = Color.new(96, 96, 96)
    @language = pbGetSelectedLanguage

    @viewport = Viewport.new(0, 0, viewport.width, viewport.height)
    @viewport.z = viewport.z + 5

    # Configure initial sprites
    @sprites = {}
    @items = {}
    @sprites["back"] = Sprite.new(viewport)
    @sprites["back"].stretch_screen(@path + "shade")
    @sprites["back"].opacity = 0
    @sprites["back"].z = 99998

    bag = scene.instance_variable_get(:@bagWindow)
    @bag_visible = bag && !bag.disposed? && bag.sprites && bag.sprites["pocket0"] && bag.sprites["pocket0"].visible
    @sprites["back"].visible = false if @bag_visible

    # Set up selector sprite
    @sprites["sel"] = SelectorSprite.new(@viewport, 4)
    @sprites["sel"].filename = @path + "cmdSel"
    @sprites["sel"].z = 99999

    # Title banner text sprite (transparent background since itemName banner is not in Party/)
    @sprites["name"] = Sprite.new(@viewport)
    @sprites["name"].bitmap = Bitmap.new(320, 44)
    pbSetSystemFont(@sprites["name"].bitmap)
    @sprites["name"].x = -@sprites["name"].width - @sprites["name"].width % 10
    @sprites["name"].y = @viewport.height - 56

    # Back button sprite
    langMult = "_" + @language
    @sprites["pocket5"] = Sprite.new(@viewport)
    itemBackPath = pbResolveBitmap(@path + "back" + langMult)
    @sprites["pocket5"].bitmap = itemBackPath ? pbBitmap(itemBackPath) : pbBitmap(@path + "back")
    @sprites["pocket5"].x = @viewport.width - @sprites["pocket5"].width - 16
    @sprites["pocket5"].ey = @viewport.height - 60
    @sprites["pocket5"].y = @sprites["pocket5"].ey + 80
    @sprites["pocket5"].z = 5

    # confirmation buttons
    @sprites["confirm"] = Sprite.new(@viewport)
    itemConfirmPath = pbResolveBitmap(@path + "itemConfirm" + langMult)
    bmp = itemConfirmPath ? pbBitmap(itemConfirmPath) : pbBitmap(@path + "itemConfirm")
    @sprites["confirm"].bitmap = Bitmap.new(bmp.width, bmp.height)
    pbSetSmallFont(@sprites["confirm"].bitmap)
    bmp.dispose
    @sprites["confirm"].center!
    @sprites["confirm"].x = @viewport.width/2 - @viewport.width + @viewport.width%8
    @sprites["confirm"].visible = false # hide initially

    @sprites["cancel"] = Sprite.new(@viewport)
    itemCancelPath = pbResolveBitmap(@path + "itemCancel" + langMult)
    bmp_c = itemCancelPath ? pbBitmap(itemCancelPath) : pbBitmap(@path + "itemCancel")
    @sprites["cancel"].bitmap = Bitmap.new(bmp_c.width, bmp_c.height)
    bmp_c.dispose
    @sprites["cancel"].center!
    @sprites["cancel"].x = @viewport.width/2 - @viewport.width + @viewport.width%8
    @sprites["cancel"].visible = false # hide initially

    # calculate y values for the confirm/cancel buttons
    maxh = @sprites["confirm"].height + @sprites["cancel"].height + 8
    @sprites["confirm"].y = (@viewport.height - maxh)/2 + @sprites["confirm"].oy
    @sprites["cancel"].y = (@viewport.height - maxh)/2 + maxh - @sprites["cancel"].oy

    # Load the party pokemon buttons
    self.drawParty
  end

  def inspect
    return "#<BattlePartyWindowEBDX party_size:#{@party.length}>"
  end

  def dispose
    keys = ["back", "sel", "name", "pocket5", "confirm", "cancel"]
    keys.each { |key| @sprites[key].dispose if @sprites[key] }
    pbDisposeSpriteHash(@items)
    @disposed = true
  end

  def disposed?
    return @disposed
  end

  def drawParty
    @pocket = []
    @party.each_with_index do |pkmn, i|
      next if !pkmn
      @pocket.push([pkmn, i])
    end

    @xpos = []
    @pages = @pocket.length / 6
    @pages += 1 if @pocket.length % 6 > 0
    @pages = 1 if @pages == 0
    @page = 0
    @item = 0
    @olditem = 0
    @back = false

    pbDisposeSpriteHash(@items)
    @items = {}
    @pname = _INTL("Choose a Pokemon")

    x = 0; y = 0
    ibmp = pbBitmap(@path + "itemFrame")

    @pocket.each_with_index do |data, i|
      pkmn = data[0]
      @items["#{i}"] = Sprite.new(@viewport)
      @items["#{i}"].bitmap = Bitmap.new(ibmp.width, ibmp.height)
      @items["#{i}"].bitmap.blt(0, 0, ibmp, ibmp.rect)
      pbSetSystemFont(@items["#{i}"].bitmap)

      # Pokemon Icon
      icon = pbBitmap(GameData::Species.icon_filename_from_pokemon(pkmn))
      icon_rect = Rect.new(0, 0, icon.height, icon.height)
      # Position the icon on the right side of the item frame, centered vertically
      icon_x = ibmp.width - icon.height - 4
      icon_y = (ibmp.height - icon.height)/2
      @items["#{i}"].bitmap.blt(icon_x, icon_y, icon, icon_rect, 164)
      icon.dispose

      # Pokemon name and level text
      y1 = ibmp.height / 8
      y2 = ibmp.height / 2
      text = [
        ["#{pkmn.name}", ibmp.width/2 - 15, y1, 2, @baseColor, Color.new(0, 0, 0, 32)],
        [_INTL("Lv. {1}", pkmn.level), ibmp.width/2 - 12, y2, 2, @baseColor, Color.new(0, 0, 0, 32)]
      ]
      pbDrawTextPositions(@items["#{i}"].bitmap, text)

      @items["#{i}"].center!
      @items["#{i}"].x = @viewport.width + (x%2 == 0 ? 1 : -1)*8 + (x*2 + 1)*@viewport.width/4 + (i/6)*@viewport.width
      @xpos.push(@items["#{i}"].x - @viewport.width)
      @items["#{i}"].y = (y + 1)*@viewport.height/5 + (y*12)
      @items["#{i}"].opacity = 255

      x += 1; y += 1 if x > 1
      x = 0 if x > 1
      y = 0 if y > 2
    end
    ibmp.dispose
    self.name
    @sprites["name"].x = -@sprites["name"].width - @sprites["name"].width%10

    # Target selection to current item
    @sprites["sel"].target(@back ? @sprites["pocket5"] : @items["#{@item}"])
  end

  def name
    bitmap = @sprites["name"].bitmap
    bitmap.clear
    text = [
      [@pname, 160, 8, 2, Color.white, Color.new(0, 0, 0, 128)]
    ]
    pbDrawTextPositions(bitmap, text)
  end

  def show
    @ret = nil
    @finished = false
    @sprites["pocket5"].y = @sprites["pocket5"].ey + 80
    @sprites["pocket5"].opacity = 255
    @pocket.length.times do |i|
      @items["#{i}"].opacity = 0 if @items["#{i}"]
    end
    pbSEPlay("EBDX/SE_Zoom4", 60)
    8.times do
      @sprites["pocket5"].y -= 10
      @sprites["back"].opacity += 32 if !@bag_visible
      @sprites["sel"].update
      @scene.wait(1, true)
    end
  end

  def hide
    8.times do
      @sprites["pocket5"].y += 10
      @pocket.length.times do |i|
        @items["#{i}"].opacity -= 25.5 if @items["#{i}"]
      end
      @sprites["name"].x -= 48 if @sprites["name"].x > -380
      @sprites["back"].opacity -= 32 if !@bag_visible
      @sprites["sel"].update
      @scene.wait(1, true)
    end
  end

  def visible=(val)
    for key in @sprites.keys
      next if key == "back"
      @sprites[key].visible = val
    end
    @pocket.length.times do |i|
      @items["#{i}"].visible = val if @items["#{i}"]
    end
  end

  def update
    self.updatePocket
    @sprites["back"].opacity += 51 if @sprites["back"].opacity < 255
    @sprites["pocket5"].y -= 8 if @sprites["pocket5"].y > @sprites["pocket5"].ey
    @pocket.length.times do |i|
      @items["#{i}"].opacity += 51 if @items["#{i}"] && @items["#{i}"].opacity < 255
    end
    @sprites["sel"].update
  end

  def updatePocket
    @page = @item / 6
    for i in 0...@pocket.length
      next if !@items["#{i}"]
      @items["#{i}"].x -= (@items["#{i}"].x - (@xpos[i] - @page*@viewport.width))*0.2
      @items["#{i}"].src_rect.y += 1 if @items["#{i}"].src_rect.y < 0
    end
    @sprites["name"].x += @sprites["name"].width/10 if @sprites["name"].x < -24
    @sprites["pocket5"].src_rect.y += 1 if @sprites["pocket5"].src_rect.y < 0

    start_idx = @page * 6
    end_idx = [start_idx + 6, @pocket.length].min

    animating = false
    for i in start_idx...end_idx
      next if !@items["#{i}"]
      target_x = @xpos[i] - @page * @viewport.width
      if (@items["#{i}"].x - target_x).abs > 16
        animating = true
        break
      end
    end

    buttons = {}
    buttons[:back] = @sprites["pocket5"]
    if !animating
      for i in start_idx...end_idx
        buttons[i] = @items["#{i}"] if @items["#{i}"]
      end
    end

    current_sel = @back ? :back : @item
    action, val = Mouse::UISelection.input_action(buttons, current_sel)

    case action
    when :highlight
      if val == :back
        @back = true
      else
        @back = false
        @item = val
      end
    when :select
      if val == :back
        pbSEPlay("EBDX/SE_Select3")
        @finished = true
      else
        pbSEPlay("EBDX/SE_Select2")
        @ret = @pocket[@item][1]
      end
    when :cancel
      pbSEPlay("EBDX/SE_Select3")
      @finished = true
    when :scroll_up
      old_item = @item
      if @back
        @back = false
        @item = [(@item / 6 - 1) * 6, 0].max
      else
        @item -= 6
        @item = 0 if @item < 0
      end
      @item = 0 if @item < 0
      @item = @pocket.length - 1 if @item > @pocket.length - 1
      pbSEPlay("EBDX/SE_Select1") if @item != old_item || @back
    when :scroll_down
      old_item = @item
      if @back
        @back = false
        @item = [(@item / 6 + 1) * 6, @pocket.length - 1].min
      else
        @item += 6
        @item = @pocket.length - 1 if @item > @pocket.length - 1
      end
      @item = 0 if @item < 0
      @item = @pocket.length - 1 if @item > @pocket.length - 1
      pbSEPlay("EBDX/SE_Select1") if @item != old_item || @back
    end

    if action.nil?
      if Input.trigger?(Input::LEFT) && !@back
        if ![0, 2, 4].include?(@item)
          @item -= (@item%2 == 0) ? 5 : 1
        else
          @item -= 1 if @item < 0
        end
        @item = 0 if @item < 0
      elsif Input.trigger?(Input::RIGHT) && !@back
        if @page < (@pocket.length)/6
          @item += (@item%2 == 1) ? 5 : 1
        else
          @item += 1 if @item < @pocket.length - 1
        end
        @item = @pocket.length - 1 if @item > @pocket.length - 1
      elsif Input.trigger?(Input::UP)
        if @back
          @item += 4 if (@item%6) < 2
          @back = false
        else
          @item -= 2
          if (@item%6) > 3
            @item += 6
            @back = true
          end
        end
        @item = 0 if @item < 0
        @item = @pocket.length-1 if @item > @pocket.length-1
        @sprites["pocket5"].src_rect.y -= 6 if @back
      elsif Input.trigger?(Input::DOWN)
        if @back
          @item -= 4 if (@item%6) > 3
          @back = false
        else
          @item += 2
          if (@item%6) < 2
            @item -= 6
            @back = true
          end
          @back = true if @item > @pocket.length - 1
        end
        @item = @pocket.length - 1 if @item > @pocket.length - 1
        @item = 0 if @item < 0
        @sprites["pocket5"].src_rect.y -= 6 if @back
      elsif Input.trigger?(Input::C)
        if @back
          pbSEPlay("EBDX/SE_Select3")
          @finished = true
        else
          pbSEPlay("EBDX/SE_Select2")
          @ret = @pocket[@item][1]
        end
      elsif Input.trigger?(Input::B)
        pbSEPlay("EBDX/SE_Select3")
        @finished = true
      end
    end

    if @item != @olditem || @back != @oldback
      @olditem = @item
      @oldback = @back
      pbSEPlay("EBDX/SE_Select1")
      @sprites["sel"].target(@back ? @sprites["pocket5"] : @items["#{@item}"])
      @items["#{@item}"].src_rect.y -= 6 if !@back && @items["#{@item}"]
      self.name
    end
  end

  def showCommands(msg, commands)
    Input.update
    sprite_x = 200
    cmd_y = 8
    name_x = 20
    name_y = 36
    level_x = 160
    level_y = 36
    hp_bar_x = 20
    hp_bar_y = 84
    hp_text_x = -116
    hp_text_y = 112
    hp_bar_width = 168
    baseColor = Color.white
    shadowColor = Color.new(0, 0, 0, 160)

    @pname = msg
    self.name
    has_switch = commands.any? { |c| c == _INTL("Switch In") || c == _INTL("Send to Boxes") }
    bitmap1 = @sprites["confirm"].bitmap
    bitmap1.clear
    bmp1 = pbBitmap(@path + "itemConfirm")
    bitmap1.blt(0, 0, bmp1, bmp1.rect)
    bmp1.dispose
    pkmn = @party[@item]

    # Draw Pokemon front sprite on the Confirm button (native size)
    front_bmp_wrapper = GameData::Species.sprite_bitmap_from_pokemon(pkmn, false)
    front_bmp = front_bmp_wrapper.bitmap
    sprite_y = (bitmap1.height - front_bmp.height) / 2
    bitmap1.blt(sprite_x, sprite_y, front_bmp, front_bmp.rect, 204)
    front_bmp_wrapper.dispose

    # Draw Pokemon Name, Level, and HP details on Confirm button
    pbSetSystemFont(bitmap1)
    pbDrawOutlineText(bitmap1, name_x, name_y, bitmap1.width, 32, pkmn.name, baseColor, shadowColor, 0)

    level_text = "Lv. #{pkmn.level}"
    pbDrawOutlineText(bitmap1, level_x, level_y, bitmap1.width, 32, level_text, baseColor, shadowColor, 0)

    # Draw HP Bar and Container in EBDX style
    colors_bmp = pbBitmap(@path + "barColors")
    container_bmp = pbBitmap(@path + "containers")

    # HP container (height 14 for no EXP)
    container_rect = Rect.new(0, 0, container_bmp.width, 14)
    bitmap1.blt(hp_bar_x, hp_bar_y, container_bmp, container_rect)

    # HP bar fill
    if pkmn.hp > 0
      w = (pkmn.hp * hp_bar_width / pkmn.totalhp.to_f).round
      w = 1 if w < 1
      zone = 0
      zone = 1 if pkmn.hp <= pkmn.totalhp * 0.50
      zone = 2 if pkmn.hp <= pkmn.totalhp * 0.25
      bar_rect = Rect.new(zone * 2, 0, 2, 6)
      bitmap1.stretch_blt(Rect.new(hp_bar_x + 4, hp_bar_y + 2, w, 6), colors_bmp, bar_rect)
    end

    # HP Text (HP/TOTALHP)
    hp_text = "#{pkmn.hp}/#{pkmn.totalhp}"
    pbDrawOutlineText(bitmap1, hp_text_x, hp_text_y, bitmap1.width, 32, hp_text, baseColor, shadowColor, 1)

    if has_switch
      option_title1 = (commands.include?(_INTL("Switch In"))) ? _INTL("SWITCH IN") : _INTL("SEND TO BOXES")
      pbDrawOutlineText(bitmap1, 0, cmd_y, sprite_x, 32, option_title1, baseColor, shadowColor, 1)

      bitmap2 = @sprites["cancel"].bitmap
      bitmap2.clear
      bmp2 = pbBitmap(@path + "itemCancel")
      bitmap2.blt(0, 0, bmp2, bmp2.rect)
      bmp2.dispose

      option_title2 = _INTL("SUMMARY")
      pbSetSystemFont(bitmap2)
      pbDrawOutlineText(bitmap2, 0, (bitmap2.height - 24)/2, bitmap2.width, 24, option_title2, baseColor, shadowColor, 1)

      maxh = @sprites["confirm"].height + @sprites["cancel"].height + 8
      @sprites["confirm"].y = (@viewport.height - maxh)/2 + @sprites["confirm"].oy
      @sprites["cancel"].y = (@viewport.height - maxh)/2 + maxh - @sprites["cancel"].oy

      @sprites["confirm"].visible = true
      @sprites["cancel"].visible = true
    else
      option_title1 = _INTL("SUMMARY")
      pbDrawOutlineText(bitmap1, 0, cmd_y, sprite_x, 32, option_title1, baseColor, shadowColor, 1)

      @sprites["confirm"].y = (@viewport.height - @sprites["confirm"].height)/2 + @sprites["confirm"].oy

      @sprites["confirm"].visible = true
      @sprites["cancel"].visible = false
    end

    @sprites["pocket5"].y = @sprites["pocket5"].ey
    @sprites["pocket5"].opacity = 255
    @sprites["pocket5"].visible = true

    orig_confirm_x = @viewport.width/2
    orig_cancel_x = @viewport.width/2

    @sprites["confirm"].x = orig_confirm_x - @viewport.width
    @sprites["cancel"].x = orig_cancel_x - @viewport.width if has_switch

    8.times do
      @sprites["confirm"].x += @viewport.width/8
      @sprites["cancel"].x += @viewport.width/8 if has_switch

      @pocket.length.times do |i|
        @items["#{i}"].opacity -= 32 if @items["#{i}"]
      end

      @sprites["sel"].update
      @scene.animateScene
      @scene.pbGraphicsUpdate
    end

    @sprites["confirm"].x = orig_confirm_x
    @sprites["cancel"].x = orig_cancel_x if has_switch

    @sprites["sel"].target(@sprites["confirm"])
    @sprites["sel"].update

    index = 0
    oldindex = 0
    choice_sprite = @sprites["confirm"]
    num_options = has_switch ? 3 : 2

    loop do
      choice_sprite.src_rect.y += 1 if choice_sprite.src_rect.y < 0
      @sprites["pocket5"].src_rect.y += 1 if @sprites["pocket5"].src_rect.y < 0

      # Mouse hover and click support
      mouse_acted = false
      if Mouse::UISelection.active?
        buttons = {}
        buttons[0] = @sprites["confirm"]
        if has_switch
          buttons[1] = @sprites["cancel"]
          buttons[2] = @sprites["pocket5"]
        else
          buttons[1] = @sprites["pocket5"]
        end

        mouse_action = Mouse::UISelection.update_menu(buttons, index)
        if mouse_action
          action, val = mouse_action
          case action
          when :highlight
            index = val
            if index == 0
              choice_sprite = @sprites["confirm"]
            elsif index == 1
              choice_sprite = has_switch ? @sprites["cancel"] : @sprites["pocket5"]
            else
              choice_sprite = @sprites["pocket5"]
            end
          when :select
            pbSEPlay("EBDX/SE_Select2")
            mouse_acted = true
            break
          when :cancel
            @scene.pbPlayCancelSE()
            index = num_options - 1
            mouse_acted = true
            break
          end
        end
      end

      if !mouse_acted
        if has_switch
          if Input.trigger?(Input::UP)
            index -= 1
            index = 2 if index < 0
          elsif Input.trigger?(Input::DOWN)
            index += 1
            index = 0 if index > 2
          end
        else
          if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
            index = (index == 0) ? 1 : 0
          end
        end
      end

      if index != oldindex
        oldindex = index
        pbSEPlay("EBDX/SE_Select1")

        if index == 0
          choice_sprite = @sprites["confirm"]
        elsif index == 1
          choice_sprite = has_switch ? @sprites["cancel"] : @sprites["pocket5"]
        else
          choice_sprite = @sprites["pocket5"]
        end

        choice_sprite.src_rect.y -= 6
        @sprites["sel"].target(choice_sprite)
      end

      if !mouse_acted
        if Input.trigger?(Input::C)
          pbSEPlay("EBDX/SE_Select2")
          break
        elsif Input.trigger?(Input::B)
          @scene.pbPlayCancelSE()
          index = num_options - 1
          break
        end
      end

      Input.update
      @sprites["sel"].update
      @scene.animateScene
      @scene.pbGraphicsUpdate
    end

    # 5. Animate them sliding out
    8.times do
      @sprites["confirm"].x -= @viewport.width/8
      @sprites["cancel"].x -= @viewport.width/8 if has_switch

      # Fade in pokemon buttons
      @pocket.length.times do |i|
        @items["#{i}"].opacity += 32 if @items["#{i}"]
      end

      @sprites["sel"].update
      @scene.animateScene
      @scene.pbGraphicsUpdate
    end

    # Hide confirm/cancel
    @sprites["confirm"].visible = false
    @sprites["cancel"].visible = false

    # Restore target selection to current item
    @sprites["sel"].target(@back ? @sprites["pocket5"] : @items["#{@item}"])

    # Restore the header title text
    @pname = _INTL("Choose a Pokemon")
    self.name

    return index
  end

  def pbChoosePokemon
    Input.update
    @ret = nil
    @finished = false
    loop do
      Input.update
      self.update
      if @finished
        return -1
      end
      if !@ret.nil?
        val = @ret
        @ret = nil
        return val
      end
      @scene.animateScene
      @scene.pbGraphicsUpdate
    end
  end

  def clearSel
    @sprites["sel"].bitmap = Bitmap.new(2, 2)
  end
end

class PokemonBattleParty_Scene
  attr_accessor :partyWindow
  attr_accessor :sprites

  def initialize
    @partyWindow = nil
    @sprites = {}
  end

  def pbStartScene(party)
  end

  def pbSetHelpText(msg)
  end

  def pbDisplay(text)
    @partyWindow.scene.pbDisplay(text)
  end

  def pbShowCommands(msg, commands, index = 0)
    return @partyWindow.showCommands(msg, commands)
  end

  def pbSummary(pkmnid, inbattle = false)
    oldsprites = pbFadeOutAndHide(@sprites)
    # @partyWindow.visible = false
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene, inbattle)
    screen.pbStartScreen(@partyWindow.party, pkmnid)
    pbFadeInAndShow(@sprites, oldsprites)
  end

  def pbEndScene
    if @partyWindow
      @partyWindow.clearSel
      @partyWindow.hide
      @partyWindow.dispose
      @partyWindow = nil
      @sprites = {}
    end
  end
end

class PokemonBattlePartyScreen
  attr_reader :scene
  attr_reader :party

  def initialize(battle_scene, scene, party)
    @battle_scene = battle_scene
    @scene = scene
    @party = party
  end

  def pbStartScene(helptext, numBattlersOut, annotations = nil)
    @scene.partyWindow = BattlePartyWindowEBDX.new(@battle_scene, @battle_scene.msgview, @party)
    @scene.sprites = @scene.partyWindow.sprites.clone
    @scene.partyWindow.items.each do |k, v|
      @scene.sprites["item_#{k}"] = v
    end
    @scene.partyWindow.show
  end

  def pbDisplay(text)
    @battle_scene.pbDisplay(text)
  end

  def pbChoosePokemon
    return @scene.partyWindow.pbChoosePokemon
  end

  def pbEndScene
    @scene.pbEndScene
  end
end

#===============================================================================
#  Override Battle::Scene methods to use the new UI classes in battle
#===============================================================================
class Battle::Scene
  attr_reader :msgview
  #-----------------------------------------------------------------------------
  #  Override main battle party screen
  #-----------------------------------------------------------------------------
  def pbPartyScreen(idxBattler, canCancel = false, mode = 0)
    partyPos = @battle.pbPartyOrder(idxBattler)
    partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    modParty = @battle.pbPlayerDisplayParty(idxBattler)

    scene = PokemonBattleParty_Scene.new
    switchScreen = PokemonBattlePartyScreen.new(self, scene, modParty)
    msg = _INTL("Choose a Pokémon.")
    msg = _INTL("Send which Pokémon to Boxes?") if mode == 1
    switchScreen.pbStartScene(msg, @battle.pbNumPositions(0, 0))

    loop do
      scene.pbSetHelpText(msg)
      idxParty = switchScreen.pbChoosePokemon
      if idxParty < 0
        next if !canCancel
        break
      end

      cmdSwitch  = -1
      cmdBoxes   = -1
      cmdSummary = -1
      commands = []
      commands[cmdSwitch  = commands.length] = _INTL("Switch In") if mode == 0 && modParty[idxParty].able? &&
                                                                     (@battle.canSwitch || !canCancel)
      commands[cmdBoxes   = commands.length] = _INTL("Send to Boxes") if mode == 1
      commands[cmdSummary = commands.length] = _INTL("Summary")
      commands[commands.length]              = _INTL("Cancel")

      command = scene.pbShowCommands(_INTL("Do what with {1}?", modParty[idxParty].name), commands)
      if (cmdSwitch >= 0 && command == cmdSwitch) || (cmdBoxes >= 0 && command == cmdBoxes)
        idxPartyRet = -1
        partyPos.each_with_index do |pos, i|
          next if pos != idxParty + partyStart
          idxPartyRet = i
          break
        end
        break if yield idxPartyRet, switchScreen
      elsif cmdSummary >= 0 && command == cmdSummary
        scene.pbSummary(idxParty, true)
      end
    end

    switchScreen.pbEndScene
  end

  #-----------------------------------------------------------------------------
  #  Override item selection target targeting
  #-----------------------------------------------------------------------------
  alias pbItemMenu_party_ebdx pbItemMenu unless self.method_defined?(:pbItemMenu_party_ebdx)
  def pbItemMenu(idxBattler, firstAction)
    @idleTimer = -1
    @vector.reset; @vector.inc = 0.2
    ret = 0; retindex = -1; pkmnid = -1
    Input.update
    @bagWindow.show

    loop do
      Input.update
      @bagWindow.update
      break if @bagWindow.finished

      if !@bagWindow.ret.nil? && @bagWindow.useItem?
        item = GameData::Item.get(@bagWindow.ret)
        itemName = item.name
        useType = item.battle_use

        case useType
        when 1, 2, 3, 6, 7, 8   # Use on Pokémon/Pokémon's move/battler
          case useType
          when 1, 6   # Use on Pokémon
            if @battle.pbTeamLengthFromBattlerIndex(idxBattler) == 1
              ret = item
              break if yield item.id, useType, @battle.battlers[idxBattler].pokemonIndex, -1, @bagWindow
            end
          when 3, 8   # Use on battler
            if @battle.pbPlayerBattlerCount == 1
              ret = item
              break if yield item.id, useType, @battle.battlers[idxBattler].pokemonIndex, -1, @bagWindow
            end
          end

          party    = @battle.pbParty(idxBattler)
          partyPos = @battle.pbPartyOrder(idxBattler)
          partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
          modParty = @battle.pbPlayerDisplayParty(idxBattler)

          @bagWindow.clearSel
          pkmnScene = PokemonBattleParty_Scene.new
          pkmnScreen = PokemonBattlePartyScreen.new(self, pkmnScene, modParty)
          pkmnScreen.pbStartScene(_INTL("Use on which Pokémon?"), @battle.pbNumPositions(0, 0))
          idxParty = -1

          loop do
            pkmnScene.pbSetHelpText(_INTL("Use on which Pokémon?"))
            idxParty = pkmnScreen.pbChoosePokemon
            break if idxParty < 0

            idxPartyRet = -1
            partyPos.each_with_index do |pos, i|
              next if pos != idxParty + partyStart
              idxPartyRet = i
              break
            end
            next if idxPartyRet < 0

            pkmn = party[idxPartyRet]
            next if !pkmn || pkmn.egg?

            idxMove = -1
            if useType == 2 || useType == 7   # Use on Pokémon's move
              idxMove = pkmnScreen.pbChooseMove(pkmn, _INTL("Restore which move?"))
              next if idxMove < 0
            end
            break if yield item.id, useType, idxPartyRet, idxMove, pkmnScene
          end

          pkmnScene.pbEndScene
          break if idxParty >= 0

        when 4, 9   # Use on opposing battler (Poké Balls)
          idxTarget = -1
          if @battle.pbOpposingBattlerCount(idxBattler) == 1
            @battle.eachOtherSideBattler(idxBattler) { |b| idxTarget = b.index }
            ret = item
            break if yield item.id, useType, idxTarget, -1, @bagWindow
          else
            wasTargeting = true
            @bagWindow.sprites["back"].opacity = 0
            idxTarget = pbChooseTarget(idxBattler, GameData::Target.get(:Foe), {})
            if idxTarget >= 0
              ret = item
              break if yield item.id, useType, idxTarget, -1, self
            end
            wasTargeting = false
          end
          @bagWindow.closeCurrent

        when 5, 10   # Use with no target
          ret = item
          break if yield item.id, useType, idxBattler, -1, @bagWindow
        end
      end
      self.animateScene
      pbGraphicsUpdate
    end

    @bagWindow.clearSel
    @bagWindow.hide
    if ret.nil? && !(ret.is_a?(Numeric))
      numId = EliteBattle.GetItemID(ret.id)
      $lastUsed = nil if (numId > 0 && $bag.quantity(ret) <= 1)
    else
      $lastUsed = nil
    end
    setBGMLowHP(false)
  end
end
