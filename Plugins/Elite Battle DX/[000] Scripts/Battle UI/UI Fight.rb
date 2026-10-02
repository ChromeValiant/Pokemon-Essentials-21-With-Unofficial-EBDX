#===============================================================================
#  Fight Menu functionality part
#===============================================================================
class Battle::Scene
  #-----------------------------------------------------------------------------
  #  main fight menu override
  #-----------------------------------------------------------------------------
  def pbFightMenu(idxBattler, megaEvoPossible = false)
    # refresh current UI
    battler = @battle.battlers[idxBattler]
    self.clearMessageWindow
    @fightWindow.battler = battler
    @fightWindow.megaButton if megaEvoPossible && @battle.pbCanMegaEvolve?(idxBattler)
    # last chosen move
    moveIndex = 0
    if battler.moves[@lastMove[idxBattler]] && battler.moves[@lastMove[idxBattler]].id
      moveIndex = @lastMove[idxBattler]
    end
    @fightWindow.index = (battler.moves[moveIndex].id != 0) ? moveIndex : 0
    # setup button bitmaps
    @fightWindow.generateButtons
    # play UI animation
    @sprites["dataBox_#{idxBattler}"].selected = true
    pbSEPlay("EBDX/SE_Zoom4", 50)
    @fightWindow.showPlay
    loop do
      oldIndex = @fightWindow.index
      # General update
      self.updateWindow(@fightWindow)
      # Mouse hover and click support
      if Mouse::UISelection.active?
        buttons = {}
        for i in 0...@fightWindow.nummoves
          buttons[i] = @fightWindow.button["#{i}"]
        end
        
        # Check Mega Evolution button click first
        if megaEvoPossible && @fightWindow.megaButton #&& @fightWindow.megaButton.y < Graphics.height
          if Mouse.click?(@fightWindow.megaButton, :left)
            @fightWindow.megaButtonTrigger
            pbSEPlay("EBDX/SE_Select3")
            break if yield -2
          end
        end

        action, val = Mouse::UISelection.input_action(buttons, @fightWindow.index)
        case action
        when :highlight
          @fightWindow.index = val
        when :select
          pbSEPlay("EBDX/SE_Select2")
          break if yield @fightWindow.index
        when :cancel
          pbPlayCancelSE
          break if yield -1
        end
      end
      # Update selected command
      if (Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT))
        @fightWindow.index = [0, 1, 2, 3][[1, 0, 3, 2].index(@fightWindow.index)]
        @fightWindow.index = (@fightWindow.nummoves - 1) if @fightWindow.index < 0
        @fightWindow.index = 0 if @fightWindow.index > (@fightWindow.nummoves - 1)
      elsif (Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN))
        @fightWindow.index = [0, 1, 2, 3][[2, 3, 0, 1].index(@fightWindow.index)]
        @fightWindow.index = 0 if @fightWindow.index < 0
        @fightWindow.index = (@fightWindow.nummoves - 1) if @fightWindow.index > (@fightWindow.nummoves - 1)
      elsif Input.trigger?(Input::LEFT) && @fightWindow.index < 4
        if @fightWindow.index > 0
          @fightWindow.index -= 1
        else
          @fightWindow.index = @fightWindow.nummoves - 1
          @fightWindow.refreshpos = true
        end
      elsif Input.trigger?(Input::RIGHT) && @fightWindow.index < 4
        if @fightWindow.index < (@fightWindow.nummoves - 1)
          @fightWindow.index += 1
        else
          @fightWindow.index = 0
        end
      end
      # play SE
      pbSEPlay("EBDX/SE_Select1") if @fightWindow.index != oldIndex
      # Actions
      if Input.trigger?(Input::A)                                            # Toggle Mega Evolution
        if megaEvoPossible
            @fightWindow.megaButtonTrigger
            pbSEPlay("EBDX/SE_Select3")
          end
          break if yield -2
      end
    end
    # reset parameters
    self.pbResetParams if @ret > -1
    # hide window
    @fightWindow.hidePlay
    # unselect databoxes
    self.pbDeselectAll
    # set last used move
    @lastMove[idxBattler] = @fightWindow.index
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Fight Menu (Next Generation)
#  UI ovarhaul
#===============================================================================
class FightWindowEBDX
  attr_accessor :index
  attr_accessor :battler
  attr_accessor :refreshpos
  attr_reader :nummoves
  attr_reader :button, :megaButton
  #-----------------------------------------------------------------------------
  #  class inspector
  #-----------------------------------------------------------------------------
  def inspect
    str = self.to_s.chop
    str << format(' index: %s>', @index)
    return str
  end
  #-----------------------------------------------------------------------------
  #  constructor
  #-----------------------------------------------------------------------------
  def initialize(viewport = nil, battle = nil, scene = nil)
    @viewport = viewport
    @battle = battle
    @scene = scene
    @index = 0
    @oldindex = -1
    @over = false
    @refreshpos = false
    @battler = nil
    @nummoves = 0

    @opponent = nil
    @player = nil
    @opponent = @battle.battlers[1] if !@battle.doublebattle?
    @player = @battle.battlers[0] if !@battle.doublebattle?

    @path = "Graphics/EBDX/Pictures/UI/"
    self.applyMetrics

    @buttonBitmap = pbBitmap(@path + @cmdImg)
    
    lang = pbGetSelectedLanguage
    typeBitmapPath = pbResolveBitmap("Graphics/EBDX/Pictures/UI/types_"+lang)

    if typeBitmapPath
      @typebitmap = pbBitmap(typeBitmapPath)
    else
      @typebitmap = pbBitmap(@path + @typImg)
    end    
 
    if !@typebitmap
      @typebitmap = pbBitmap("Graphics/EBDX/Pictures/UI/types")
    end

    @catBitmap = pbBitmap(@path + @catImg)

    @background = Sprite.new(@viewport)
    @background.create_rect(@viewport.width,64,Color.new(0,0,0,150))
    @background.bitmap = pbBitmap(@path + @barImg) if !@barImg.nil?
    @background.y = Graphics.height - @background.bitmap.height
    @background.z = 100

    @megaButton = Sprite.new(@viewport)
    @megaButton.bitmap = pbBitmap(@path + @megaImg)
    @megaButton.z = 101
    @megaButton.src_rect.width /= 2
    @megaButton.center!
    @megaButton.x = 30
    @megaButton.y = @viewport.height - @background.bitmap.height/2 + 100

    @sel = SpriteSheet.new(@viewport,4)
    @sel.setBitmap(pbSelBitmap(@path + @selImg,Rect.new(0,0,192,68)))
    @sel.speed = 4
    @sel.ox = @sel.src_rect.width/2
    @sel.oy = @sel.src_rect.height/2
    @sel.z = 199
    @sel.visible = false

    @button = {}
    @moved = false
    @showMega = false
	@sprites ||= {}

    eff = [_INTL("Normal damage"),_INTL("Not very effective"),_INTL("Super effective"),_INTL("No effect")]
    @typeInd = Sprite.new(@viewport)
    @typeInd.bitmap = Bitmap.new(192,24*4)
    pbSetSmallFont(@typeInd.bitmap)
    for i in 0...4
      pbDrawOutlineText(@typeInd.bitmap,0,24*i + 5,192,24,eff[i],Color.white,Color.black,1)
    end
    @typeInd.src_rect.set(0,0,192,24)
    @typeInd.ox = 192/2
    @typeInd.oy = 16
    @typeInd.z = 103
    @typeInd.visible = false

  end

  #-----------------------------------------------------------------------------
  #  PBS metadata
  #-----------------------------------------------------------------------------
  def applyMetrics
    # sets default values
    @cmdImg = "moveSelButtons"
    @selImg = "cmdSel"
    @typImg = "types"
    @catImg = "category"
    @megaImg = "megaButton"
    @barImg = nil
    @showTypeAdvantage = false
    # looks up next cached metrics first
    d1 = EliteBattle.get(:nextUI)
    d1 = d1[:FIGHTMENU] if !d1.nil? && d1.has_key?(:FIGHTMENU)
    # looks up globally defined settings
    d2 = EliteBattle.get_data(:FIGHTMENU, :Metrics, :METRICS)
    # looks up globally defined settings
    d7 = EliteBattle.get_map_data(:FIGHTMENU_METRICS)
    # look up trainer specific metrics
    d6 = @battle.opponent ? EliteBattle.get_trainer_data(@battle.opponent[0].trainer_type, :FIGHTMENU_METRICS, @battle.opponent[0]) : nil
    # looks up species specific metrics
    d5 = !@battle.opponent ? EliteBattle.get_data(@battle.battlers[1].species, :Species, :FIGHTMENU_METRICS, (@battle.battlers[1].form rescue 0)) : nil
    # proceeds with parameter definition if available
    for data in [d2, d7, d6, d5, d1]
      if !data.nil?
        # applies a set of predefined keys
        @megaImg = data[:MEGABUTTONGRAPHIC] if data.has_key?(:MEGABUTTONGRAPHIC) && data[:MEGABUTTONGRAPHIC].is_a?(String)
        @cmdImg = data[:BUTTONGRAPHIC] if data.has_key?(:BUTTONGRAPHIC) && data[:BUTTONGRAPHIC].is_a?(String)
        @selImg = data[:SELECTORGRAPHIC] if data.has_key?(:SELECTORGRAPHIC) && data[:SELECTORGRAPHIC].is_a?(String)
        @barImg = data[:BARGRAPHIC] if data.has_key?(:BARGRAPHIC) && data[:BARGRAPHIC].is_a?(String)
        @typImg = data[:TYPEGRAPHIC] if data.has_key?(:TYPEGRAPHIC) && data[:TYPEGRAPHIC].is_a?(String)
        @catImg = data[:CATEGORYGRAPHIC] if data.has_key?(:CATEGORYGRAPHIC) && data[:CATEGORYGRAPHIC].is_a?(String)
        @showTypeAdvantage = data[:SHOWTYPEADVANTAGE] if data.has_key?(:SHOWTYPEADVANTAGE)
      end
    end
  end
  #-----------------------------------------------------------------------------
  #  render move info buttons
  #-----------------------------------------------------------------------------
  def generateButtons
    @moves = @battler.moves
    @nummoves = 0
    @oldindex = -1
    @x = []; @y = []
    for i in 0...4
      @button["#{i}"].dispose if @button["#{i}"]
      @nummoves += 1 if @moves[i] && @moves[i].id
      @x.push(@viewport.width/2 + (i%2==0 ? -1 : 1)*(@viewport.width/2 + 99))
      @y.push(@viewport.height - 90 + (i/2)*44)
    end
    for i in 0...4
      @y[i] += 22 if @nummoves < 3
    end

    @button = {}
    for i in 0...@nummoves
      # get numeric values of required variables
      movedata = GameData::Move.get(@moves[i].id)
      category = movedata.physical? ? 0 : (movedata.special? ? 1 : 2)
      # Display correct type
      type = GetProperType(@battler, movedata).icon_position
      # create sprite
      @button["#{i}"] = Sprite.new(@viewport)
      @button["#{i}"].param = category
      @button["#{i}"].z = 102
      @button["#{i}"].bitmap = Bitmap.new(198*2, 74)
      @button["#{i}"].bitmap.blt(0, 0, @buttonBitmap, Rect.new(0, type*74, 198, 74))
      @button["#{i}"].bitmap.blt(198, 0, @buttonBitmap, Rect.new(198, type*74, 198, 74))
      @button["#{i}"].bitmap.blt(65, 46, @catBitmap, Rect.new(0, category*22, 38, 22))
      @button["#{i}"].bitmap.blt(3, 46, @typebitmap, Rect.new(0, type*22, 72, 22))
      baseColor = @buttonBitmap.get_pixel(5, 32 + (type*74)).darken(0.4)
      pbSetSmallFont(@button["#{i}"].bitmap)
      # move name: white text with a dark outline (BW2 style), identical in the
      # selected (left half) and unselected (right half) button states
      pbDrawOutlineText(@button["#{i}"].bitmap, 0, 10, 196, 42, movedata.name, Color.white, baseColor, 1)
      pbDrawOutlineText(@button["#{i}"].bitmap, 198, 10, 196, 42, movedata.name, Color.white, baseColor, 1)
	  # Display PP (with correct colouring)
      pp = "#{@moves[i].pp}/#{@moves[i].total_pp}"
      ppBase   = [Color.white,                # More than 1/2 of total PP
            Color.new(248,192,0),    # 1/2 of total PP or less
            Color.new(248,136,32),   # 1/4 of total PP or less
            Color.new(248,72,72)]    # Zero PP
      ppShadow = [baseColor,             # More than 1/2 of total PP
            Color.new(144,104,0),   # 1/2 of total PP or less
            Color.new(144,72,24),   # 1/4 of total PP or less
            Color.new(136,48,48)]   # Zero PP
      ppfraction = 0
      if @moves[i].pp==0;                  ppfraction = 3
      elsif @moves[i].pp*4<=@moves[i].total_pp; ppfraction = 2
      elsif @moves[i].pp*2<=@moves[i].total_pp; ppfraction = 1
      end
	  ppfraction = 0 if @moves[i].pp==0 && @moves[i].total_pp==0 # Shadow moves
      pbDrawOutlineText(@button["#{i}"].bitmap, 0, 48, 191, 26, pp, ppBase[ppfraction], ppShadow[ppfraction], 2)
      @button["#{i}"].src_rect.set(198, 0, 198, 74)
      @button["#{i}"].ox = @button["#{i}"].src_rect.width/2
      @button["#{i}"].x = @x[i]
      @button["#{i}"].y = @y[i]
    end
	@sprites["moveInfo"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport) # Solar Eclipse
    @sprites["moveInfo"].z = 103
    pbSetSmallFont(@sprites["moveInfo"].bitmap)
  end
  #-----------------------------------------------------------------------------
  #  unused
  #-----------------------------------------------------------------------------
  def formatBackdrop; end
  def shiftMode=(val); end
  #-----------------------------------------------------------------------------
  #  show fight menu animation
  #-----------------------------------------------------------------------------
  def show
    @sel.visible = false
    @typeInd.visible = false
	@sprites["moveInfo"].visible = true if @sprites && @sprites["moveInfo"] # Solar Eclipse
    @background.y -= (@background.bitmap.height/8)
    for i in 0...@nummoves
      @button["#{i}"].x += ((i%2 == 0 ? 1 : -1)*@viewport.width/16)
    end
  end
  def showPlay
    @megaButton.src_rect.x = 0
    @background.y = @viewport.height
    8.times do
      self.show; @scene.wait(1, true)
    end
  end
  #-----------------------------------------------------------------------------
  #  hide fight menu animation
  #-----------------------------------------------------------------------------
  def hide
    @sel.visible = false
    @typeInd.visible = false
	@sprites["moveInfo"].visible = false if @sprites && @sprites["moveInfo"] # Solar Eclipse
    @background.y += (@background.bitmap.height/8)
    @megaButton.y += 12
    for i in 0...@nummoves
      @button["#{i}"].x -= ((i%2 == 0 ? 1 : -1)*@viewport.width/16)
    end
    @showMega = false
    @megaButton.src_rect.x = 0
  end
  def hidePlay
    8.times do
      self.hide; @scene.wait(1, true)
    end
    @megaButton.y = @viewport.height - @background.bitmap.height/2 + 100
  end
  #-----------------------------------------------------------------------------
  #  toggle mega button visibility
  #-----------------------------------------------------------------------------
  def megaButton
    @showMega = true
  end
  #-----------------------------------------------------------------------------
  #  trigger mega button
  #-----------------------------------------------------------------------------
  def megaButtonTrigger
    @megaButton.src_rect.x += @megaButton.src_rect.width
    @megaButton.src_rect.x = 0 if @megaButton.src_rect.x > @megaButton.src_rect.width
    @megaButton.src_rect.y = -4
  end
  #-----------------------------------------------------------------------------
  #  update fight menu
  #-----------------------------------------------------------------------------
  def update
    @sel.visible = true
    if @showMega
      @megaButton.y -= 10 if @megaButton.y > @viewport.height - @background.bitmap.height/2
      @megaButton.src_rect.y += 1 if @megaButton.src_rect.y < 0
    end
    if @oldindex != @index
      @button["#{@index}"].src_rect.y = -4
	  # Solar Eclipse
	  move = @battler.moves[@index]
      # Show move stats
      refreshMoveInfo(move)
      # END Solar Eclipse
      if @showTypeAdvantage && !(@battle.doublebattle? || @battle.triplebattle?)
        move = @battler.moves[@index]
        @modifier = move.pbCalcTypeMod(move.type, @player, @opponent)
      end
      @oldindex = @index
    end
    for i in 0...@nummoves
      @button["#{i}"].src_rect.x = 198*(@index == i ? 0 : 1)
      @button["#{i}"].y = @y[i]
      @button["#{i}"].src_rect.y += 1 if @button["#{i}"].src_rect.y < 0
      next if i != @index
      if [0,1].include?(i)
        @button["#{i}"].y = @y[i] - ((@nummoves < 3) ? 14 : 30)
      elsif [2,3].include?(i)
        @button["#{i}"].y = @y[i] - 30
        @button["#{i-2}"].y = @y[i-2] - 30
      end
    end
    @sel.x = @button["#{@index}"].x
    @sel.y = @button["#{@index}"].y + @button["#{@index}"].src_rect.height/2 - 1
    @sel.update
    if @showTypeAdvantage && !(@battle.doublebattle? || @battle.triplebattle?)
      @typeInd.visible = true
      @typeInd.y = @button["#{@index}"].y
      @typeInd.x = @button["#{@index}"].x
      eff = 0
      if @button["#{@index}"].param == 2 # status move
        eff = 4
      elsif @modifier == 0 # No effect
        eff = 3
      elsif @modifier < 8
        eff = 1   # "Not very effective"
      elsif @modifier > 8
        eff = 2   # "Super effective"
      end
      @typeInd.src_rect.y = 24 * eff
    end
  end
  #-----------------------------------------------------------------------------
  #  draw power / accuracy / priority for the given move
  #  (never raises: a failed lookup must not take the whole battle down)
  #-----------------------------------------------------------------------------
  def refreshMoveInfo(move)
    return if !@sprites || !@sprites["moveInfo"] || @sprites["moveInfo"].disposed?
    bitmap = @sprites["moveInfo"].bitmap
    bitmap.clear
    return if !move || !move.id
    user = @battler
    begin
      movedata = GameData::Move.get(move.id)
      power = GetProperPower(user, movedata).to_s
      power = "-" if power == "0"
      acc = (move.accuracy == 0) ? "-" : GetProperAccuracy(user, movedata).to_s + "%"
      pri = GetProperPriority(user, move).to_s
    rescue StandardError
      power = (move.power == 0) ? "-" : move.power.to_s
      acc = (move.accuracy == 0) ? "-" : move.accuracy.to_s + "%"
      pri = "-"
    end
    baseX = Graphics.width - 45
    baseY = Graphics.height - 60
    lineHeight = 18
    [power, acc, pri].each_with_index do |line, i|
      pbDrawOutlineText(bitmap, baseX, baseY + i * lineHeight, Graphics.width, lineHeight,
                        line, Color.white, Color.black, 0)
    end
  end
  #-----------------------------------------------------------------------------
  #  visibility functions
  #-----------------------------------------------------------------------------
  def dispose
    @buttonBitmap.dispose
    @catBitmap.dispose
    @typeBitmap.dispose if @typeBitmap
    @background.dispose
    @megaButton.dispose
    @typeInd.dispose
    pbDisposeSpriteHash(@button)
	pbDisposeSpriteHash(@sprites)
  end
  #-----------------------------------------------------------------------------
#  custom functions
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  #  Get Proper Move Type
  #-----------------------------------------------------------------------------
  def GetProperType(battler, movedata)
    return GameData::Type.get(:NORMAL) if movedata == nil
    moveType = movedata.type

    # if movedata.function_code=="TypeDependsOnUserIVs"
      # #Hidden Power
      # return GameData::Type.get(pbHiddenPower(battler)[0])
    # end
    if movedata.id == :JUDGMENT && battler.itemActive?
      return GameData::Type.get(:NORMAL) if battler.item == nil
      case battler.item.id
      when :FISTPLATE
        return GameData::Type.get(:FIGHTING)
      when :SKYPLATE
        return GameData::Type.get(:FLYING)
      when :TOXICPLATE
        return GameData::Type.get(:POISON)
      when :EARTHPLATE
        return GameData::Type.get(:GROUND)
      when :STONEPLATE
        return GameData::Type.get(:ROCK)
      when :INSECTPLATE
        return GameData::Type.get(:BUG)
      when :SPOOKYPLATE
        return GameData::Type.get(:GHOST)
      when :IRONPLATE
        return GameData::Type.get(:STEEL)
      when :FLAMEPLATE
        return GameData::Type.get(:FIRE)
      when :SPLASHPLATE
        return GameData::Type.get(:WATER)
      when :MEADOWPLATE
        return GameData::Type.get(:GRASS)
      when :ZAPPLATE
        return GameData::Type.get(:ELECTRIC)
      when :MINDPLATE
        return GameData::Type.get(:PSYCHIC)
      when :ICICLEPLATE
        return GameData::Type.get(:ICE)
      when :DRACOPLATE
        return GameData::Type.get(:DRAGON)
      when :DREADPLATE
        return GameData::Type.get(:DARK)
      when :PIXIEPLATE
        return GameData::Type.get(:FAIRY)
      end
    end
    if movedata.id == :MULTIATTACK && battler.itemActive?
      return GameData::Type.get(:NORMAL) if battler.item == nil
      case battler.item.id
      when :FIGHTINGMEMORY
        return GameData::Type.get(:FIGHTING)
      when :FLYINGMEMORY
        return GameData::Type.get(:FLYING)
      when :POISONMEMORY
        return GameData::Type.get(:POISON)
      when :GROUNDMEMORY
        return GameData::Type.get(:GROUND)
      when :ROCKMEMORY
        return GameData::Type.get(:ROCK)
      when :BUGMEMORY
        return GameData::Type.get(:BUG)
      when :GHOSTMEMORY
        return GameData::Type.get(:GHOST)
      when :STEELMEMORY
        return GameData::Type.get(:STEEL)
      when :FIREMEMORY
        return GameData::Type.get(:FIRE)
      when :WATERMEMORY
        return GameData::Type.get(:WATER)
      when :GRASSMEMORY
        return GameData::Type.get(:GRASS)
      when :ELECTRICMEMORY
        return GameData::Type.get(:ELECTRIC)
      when :PSYCHICMEMORY
        return GameData::Type.get(:PSYCHIC)
      when :ICIMEMORY
        return GameData::Type.get(:ICE)
      when :DRAGONMEMORY
        return GameData::Type.get(:DRAGON)
      when :DARKMEMORY
        return GameData::Type.get(:DARK)
      when :FAIRYMEMORY
        return GameData::Type.get(:FAIRY)
      end
    end
    if movedata.id == :TECHNOBLAST && battler.itemActive?
      return GameData::Type.get(:NORMAL) if battler.item == nil
      case battler.item.id
      when :SHOCKDRIVE
        return GameData::Type.get(:ELECRIC)
      when :BURNDRIVE
        return GameData::Type.get(:FIRE)
      when :CHILLDRIVE
        return GameData::Type.get(:ICE)
      when :DOUSEDRIVE
        return GameData::Type.get(:WATER)
      end
    end
    if movedata.function_code=="TypeAndPowerDependOnWeather"
      # Weather Ball
	  return GameData::Type.get(:FIRE) if battler.hasActiveAbility?(:MEGASOL)
	  case battler.effectiveWeather
	  when :Sun, :HarshSun
	    return GameData::Type.get(:FIRE)
	  when :Rain, :HeavyRain
        return GameData::Type.get(:WATER)
      when :Sandstorm
        return GameData::Type.get(:ROCK)
      when :Hail
        return GameData::Type.get(:ICE)
      when :ShadowSky
        return GameData::Type.get(:SHADOW)
      end
    end
    if movedata.function_code=="TypeDependsOnUserMorpekoFormRaiseUserSpeed1"
      # Aura Wheel
      return GameData::Type.get(:DARK) if battler.isSpecies?(:MORPEKO) && battler.form == 1
    end
    if movedata.function_code=="TypeIsUserSecondType" && battler.isSpecies?(:OGERPON)
      # Ivy Cudgel
      case battler.form
      when 1, 5
        return GameData::Type.get(:WATER)
      when 2, 6
        return GameData::Type.get(:FIRE)
      when 3, 7
        return GameData::Type.get(:ROCK)
      end
    end
    if movedata.function_code=="TypeIsUserSecondTypeRemoveScreens" && battler.isSpecies?(:TAUROS)
      # Raging Bull
      return GameData::Type.get(battler.type1) || GameData::Type.get(battler.type2)
    end
    if movedata.function_code=="TypeIsUserFirstType"
      # Revelation Dance
      return GameData::Type.get(battler.type1)
    end
    if movedata.function_code=="TypeAndPowerDependOnUserBerry"
      # Natural Gift
      return GameData::Type.get(:NORMAL) if battler.item == nil
      case battler.item.id
      when :CHILANBERRY
        return GameData::Type.get(:NORMAL)
      when :CHERIBERRY,  :BLUKBERRY,   :WATMELBERRY, :OCCABERRY
        return GameData::Type.get(:FIRE)
      when :CHESTOBERRY, :NANABBERRY,  :DURINBERRY,  :PASSHOBERRY
        return GameData::Type.get(:WATER)
      when :PECHABERRY,  :WEPEARBERRY, :BELUEBERRY,  :WACANBERRY
        return GameData::Type.get(:ELECTRIC)
      when :RAWSTBERRY,  :PINAPBERRY,  :RINDOBERRY,  :LIECHIBERRY
        return GameData::Type.get(:GRASS)
      when :ASPEARBERRY, :POMEGBERRY,  :YACHEBERRY,  :GANLONBERRY
        return GameData::Type.get(:ICE)
      when :LEPPABERRY,  :KELPSYBERRY, :CHOPLEBERRY, :SALACBERRY
        return GameData::Type.get(:FIGHTING)
      when :ORANBERRY,   :QUALOTBERRY, :KEBIABERRY,  :PETAYABERRY
        return GameData::Type.get(:POISON)
      when :PERSIMBERRY, :HONDEWBERRY, :SHUCABERRY,  :APICOTBERRY
        return GameData::Type.get(:GROUND)
      when :LUMBERRY,    :GREPABERRY,  :COBABERRY,   :LANSATBERRY
        return GameData::Type.get(:FLYING)
      when :SITRUSBERRY, :TAMATOBERRY, :PAYAPABERRY, :STARFBERRY
        return GameData::Type.get(:PSYCHIC)
      when :FIGYBERRY,   :CORNNBERRY,  :TANGABERRY,  :ENIGMABERRY
        return GameData::Type.get(:BUG)
      when :WIKIBERRY,   :MAGOSTBERRY, :CHARTIBERRY, :MICLEBERRY
        return GameData::Type.get(:ROCK)
      when :MAGOBERRY,   :RABUTABERRY, :KASIBBERRY,  :CUSTAPBERRY
        return GameData::Type.get(:GHOST)
      when :AGUAVBERRY,  :NOMELBERRY,  :HABANBERRY,  :JABOCABERRY
        return GameData::Type.get(:DRAGON)
      when :IAPAPABERRY, :SPELONBERRY, :COLBURBERRY, :ROWAPBERRY, :MARANGABERRY
        return GameData::Type.get(:DARK)
      when :RAZZBERRY,   :PAMTREBERRY, :BABIRIBERRY
        return GameData::Type.get(:STEEL)
      when :ROSELIBERRY, :KEEBERRY
        return GameData::Type.get(:FAIRY)
      end
    end

    if battler.hasActiveAbility?(:AERILATE) && moveType == :NORMAL
      return GameData::Type.get(:FLYING)
    end
    if battler.hasActiveAbility?(:GALVANIZE) && moveType == :NORMAL
      return GameData::Type.get(:ELECTRIC)
    end
    if battler.hasActiveAbility?(:LIQUIDVOICE) && movedata.flags[/k/]
      return GameData::Type.get(:WATER)
    end
    if battler.hasActiveAbility?(:NORMALIZE)
      return GameData::Type.get(:NORMAL)
    end
    if battler.hasActiveAbility?(:PIXILATE) && moveType == :NORMAL
      return GameData::Type.get(:FAIRY)
    end
    if battler.hasActiveAbility?(:REFRIGERATE) && moveType == :NORMAL
      return GameData::Type.get(:ICE)
    end
	if battler.hasActiveAbility?(:DRAGONIZE) && moveType == :NORMAL
      return GameData::Type.get(:DRAGON)
    end

    return GameData::Type.get(moveType)
  end
  #-----------------------------------------------------------------------------
  #  Get Proper Move Power
  #-----------------------------------------------------------------------------
  def GetProperPower(battler, movedata)
    return "-" if movedata == nil
    movePower = movedata.power

    if movedata.function_code=="PowerHigherWithUserHappiness"
      # Return
      return [(battler.happiness*2/5).floor,1].max
    end

    if movedata.function_code=="PowerLowerWithUserHappiness"
      # Frustration
      return [((255-battler.happiness)*2/5).floor,1].max
    end

    if movedata.function_code=="PowerHigherWithUserHP"
      # Eruption, Water Spout
      return [150*battler.hp/battler.totalhp,1].max
    end

    if movedata.function_code=="ThrowUserItemAtTarget"
      # Fling
      return 0 if battler.item == nil
      case battler.item.id
      when :IRONBALL
        return 130
      when :HARDSTONE,:RAREBONE,:ARMORFOSSIL,:CLAWFOSSIL,:COVERFOSSIL,:DOMEFOSSIL,:HELIXFOSSIL,:JAWFOSSIL,:OLDAMBER,:PLUMEFOSSIL,:ROOTFOSSIL,:SAILFOSSIL,:SKULLFOSSIL
        return 100
      when :DEEPSEATOOTH,:GRIPCLAW,:THICKCLUB,:DRACOPLATE,:DREADPLATE,:EARTHPLATE,:FISTPLATE,:FLAMEPLATE,:ICICLEPLATE,:INSECTPLATE,:IRONPLATE,:MEADOWPLATE,:MINDPLATE,:PIXIEPLATE,:SKYPLATE,:SPLASHPLATE,:SPOOKYPLATE,:STONEPLATE,:TOXICPLATE,:ZAPPLATE
        return 90
      when :ASSAULTVEST,:CHIPPEDPOT,:CRACKEDPOT,:DAWNSTONE,:DUSKSTONE,:ELECTIRIZER,:HEAVYDUTYBOOTS,:MAGMARIZER,:ODDKEYSTONE,:OVALSTONE,:PROTECTOR,:QUICKCLAW,:RAZORCLAW,:SACHET,:SAFETYGOGGLES,:SHINYSTONE,:STICKYBARB,:WEAKNESSPOLICY,:WHIPPEDDREAM
        return 80
      when :DRAGONFANG,:POISONBARB,:POWERANKLET,:POWERBAND,:POWERBELT,:POWERBRACER,:POWERLENS,:POWERWEIGHT,:BURNDRIVE,:CHILLDRIVE,:DOUSEDRIVE,:SHOCKDRIVE
        return 70
      when :ADAMANTORB,:DAMPROCK,:GRISEOUSORB,:HEATROCK,:LEEK,:LUSTROUSORB,:MACHOBRACE,:ROCKYHELMET,:STICK,:TERRAINEXTENDER
        return 60
      when :DUBIOUSDISC,:SHARPBEAK,:BUGMEMORY,:DARKMEMORY,:DRAGONMEMORY,:ELECTRICMEMORY,:FAIRYMEMORY,:FIGHTINGMEMORY,:FIREMEMORY,:FLYINGMEMORY,:GHOSTMEMORY,:GRASSMEMORY,:GROUNDMEMORY,:ICEMEMORY,:POISONMEMORY,:PSYCHICMEMORY,:ROCKMEMORY,:STEELMEMORY,:WATERMEMORY
        return 50
      when :EVIOLITE,:ICYROCK,:LUCKYPUNCH
        return 40
      when :ABSORBBULB,:ADRENALINEORB,:AMULETCOIN,:BINDINGBAND,:BLACKBELT,:BLACKGLASSES,:BLACKSLUDGE,:BOTTLECAP,:CELLBATTERY,:CHARCOAL,:CLEANSETAG,:DEEPSEASCALE,:DRAGONSCALE,:EJECTBUTTON,:ESCAPEROPE,:EXPSHARE,:FLAMEORB,:FLOATSTONE,:FLUFFYTAIL,:GOLDBOTTLECAP,:HEARTSCALE,:HONEY,:KINGSROCK,:LIFEORB,:LIGHTBALL,:LIGHTCLAY,:LUCKYEGG,:LUMINOUSMOSS,:MAGNET,:METALCOAT,:METRONOME,:MIRACLESEED,:MYSTICWATER,:NEVERMELTICE,:PASSORB,:POKEDOLL,:POKETOY,:PRISMSCALE,:PROTECTIVEPADS,:RAZORFANG,:SACREDASH,:SCOPELENS,:SHELLBELL,:SHOALSALT,:SHOALSHELL,:SMOKEBALL,:SNOWBALL,:SOULDEW,:SPELLTAG,:TOXICORB,:TWISTEDSPOON,:UPGRADE,:ANTIDOTE,:AWAKENING,:BERRYJUICE,:BIGMALASADA,:BLUEFLUTE,:BURNHEAL,:CASTELIACONE,:ELIXIR,:ENERGYPOWDER,:ENERGYROOT,:ETHER,:FRESHWATER,:FULLHEAL,:FULLRESTORE,:HEALPOWDER,:HYPERPOTION,:ICEHEAL,:LAVACOOKIE,:LEMONADE,:LUMIOSEGALETTE,:MAXELIXIR,:MAXETHER,:MAXHONEY,:MAXPOTION,:MAXREVIVE,:MOOMOOMILK,:OLDGATEAU,:PARALYZEHEAL,:PARLYZHEAL,:PEWTERCRUNCHIES,:POTION,:RAGECANDYBAR,:REDFLUTE,:REVIVALHERB,:REVIVE,:SHALOURSABLE,:SODAPOP,:SUPERPOTION,:SWEETHEART,:YELLOWFLUTE,:XACCURACY,:XACCURACY2,:XACCURACY3,:XACCURACY6,:XATTACK,:XATTACK2,:XATTACK3,:XATTACK6,:XDEFEND,:XDEFEND2,:XDEFEND3,:XDEFEND6,:XDEFENSE,:XDEFENSE2,:XDEFENSE3,:XDEFENSE6,:XSPATK,:XSPATK2,:XSPATK3,:XSPATK6,:XSPECIAL,:XSPECIAL2,:XSPECIAL3,:XSPECIAL6,:XSPDEF,:XSPDEF2,:XSPDEF3,:XSPDEF6,:XSPEED,:XSPEED2,:XSPEED3,:XSPEED6,:DIREHIT,:DIREHIT2,:DIREHIT3,:ABILITYURGE,:GUARDSPEC,:ITEMDROP,:ITEMURGE,:RESETURGE,:MAXMUSHROOMS,:CALCIUM,:CARBOS,:HPUP,:IRON,:PPUP,:PPMAX,:PROTEIN,:ZINC,:RARECANDY,:EVERSTONE,:FIRESTONE,:ICESTONE,:LEAFSTONE,:MOONSTONE,:SUNSTONE,:THUNDERSTONE,:WATERSTONE,:SWEETAPPLE,:TARTAPPLE, :GALARICACUFF,:GALARICAWREATH,:MAXREPEL,:REPEL,:SUPERREPEL,:AMAZEMULCH,:BOOSTMULCH,:DAMPMULCH,:GOOEYMULCH,:GROWTHMULCH,:RICHMULCH,:STABLEMULCH,:SURPRISEMULCH,:BLUESHARD,:GREENSHARD,:REDSHARD,:YELLOWSHARD,:BALMMUSHROOM,:BIGMUSHROOM,:BIGNUGGET,:BIGPEARL,:COMETSHARD,:NUGGET,:PEARL,:PEARLSTRING,:RELICBAND,:RELICCOPPER,:RELICCROWN,:RELICGOLD,:RELICSILVER,:RELICSTATUE,:RELICVASE,:STARDUST,:STARPIECE,:STRANGESOUVENIR,:TINYMUSHROOM,:EXPCANDYXS, :EXPCANDYS, :EXPCANDYM, :EXPCANDYL, :EXPCANDYXL
        return 30
      when :CLEVERFEATHER,:GENIUSFEATHER,:HEALTHFEATHER,:MUSCLEFEATHER,:PRETTYFEATHER,:RESISTFEATHER,:SWIFTFEATHER,:CLEVERWING,:GENIUSWING,:HEALTHWING,:MUSCLEWING,:PRETTYWING,:RESISTWING,:SWIFTWING,:FAIRYFEATHER
        return 20
      when nil
        return 0
      else
        return 10
      end
    end

    if movedata.function_code=="TypeAndPowerDependOnUserBerry"
      # Natural Gift
      return 0 if battler.item == nil
      case battler.item.id
      when :WATMELBERRY,:DURINBERRY,:BELUEBERRY,:LIECHIBERRY,:GANLONBERRY,:SALACBERRY,:PETAYABERRY,:APICOTBERRY,:LANSATBERRY,:STARFBERRY,:ENIGMABERRY,:MICLEBERRY,:CUSTAPBERRY,:JABOCABERRY,:ROWAPBERRY,:KEEBERRY,:MARANGABERRY
        return 100
      when :BLUKBERRY,:NANABBERRY,:WEPEARBERRY,:PINAPBERRY,:POMEGBERRY,:KELPSYBERRY,:QUALOTBERRY,:HONDEWBERRY,:GREPABERRY,:TAMATOBERRY,:CORNNBERRY,:MAGOSTBERRY,:RABUTABERRY,:NOMELBERRY,:SPELONBERRY,:PAMTREBERRY
        return 90
      when :CHERIBERRY,:CHESTOBERRY,:PECHABERRY,:RAWSTBERRY,:ASPEARBERRY,:LEPPABERRY,:ORANBERRY,:PERSIMBERRY,:LUMBERRY,:SITRUSBERRY,:FIGYBERRY,:WIKIBERRY,:MAGOBERRY,:AGUAVBERRY,:IAPAPABERRY,:RAZZBERRY,:OCCABERRY,:PASSHOBERRY,:WACANBERRY,:RINDOBERRY,:YACHEBERRY,:CHOPLEBERRY,:KEBIABERRY,:SHUCABERRY,:COBABERRY,:PAYAPABERRY,:TANGABERRY,:CHARTIBERRY,:KASIBBERRY,:HABANBERRY,:COLBURBERRY,:BABIRIBERRY,:CHILANBERRY,:ROSELIBERRY
        return 80
      else
        return 0
      end
    end

    if movedata.function_code=="PowerHigherWithUserPositiveStatStages"
      # Power Trip, Stored Power
      mult = 1
      GameData::Stat.each_battle { |s| mult += battler.stages[s.id] if battler.stages[s.id] > 0 }
      return 20 * mult
    end

    if movedata.function_code=="PowerLowerWithUserHP"
      # Flail, Reversal
      ret = 20
      n = 48*battler.hp/battler.totalhp
      if n<2;     ret = 200
      elsif n<5;  ret = 150
      elsif n<10; ret = 100
      elsif n<17; ret = 80
      elsif n<33; ret = 40
      end
    return ret
    end
	
	if movedata.function_code=="OHKO" || movedata.function_code=="OHKOIce" || movedata.function_code=="OHKOHitsUndergroundTarget"
      # OHKO
      return "KO!"
    end

    return "???" if movePower == 1

    return movePower
  end
  #-----------------------------------------------------------------------------
  #  Get Proper Move Accuracy
  #-----------------------------------------------------------------------------
  def GetProperAccuracy(battler, movedata)
    return "-" if movedata == nil
    moveAcc = movedata.accuracy
    return moveAcc.round if battler.nil? || !battler.respond_to?(:hasActiveAbility?)

    if battler.respond_to?(:hasActiveItem?) ? battler.hasActiveItem?(:WIDELENS) : (battler.itemActive? && battler.item == :WIDELENS)
      # No Zoom Lens because it activates afterwards
      moveAcc *= 1.1
    end

    if battler.hasActiveAbility?(:HUSTLE) && movedata.category==0
      moveAcc *= 0.8
    elsif battler.hasActiveAbility?(:COMPOUNDEYES)
      moveAcc *= 1.3
    elsif battler.hasActiveAbility?(:ILLUMINATE)
      moveAcc *= 1.2
    elsif battler.hasActiveAbility?(:NOGUARD)
      return "-"
    end
    
    return moveAcc.round
  end
  #-----------------------------------------------------------------------------
  #  Get Proper Move Priority
  #-----------------------------------------------------------------------------
  def GetProperPriority(battler, movedata)
    return "-" if movedata == nil
    movePriority = movedata.priority

    if battler != nil && battler.respond_to?(:hasActiveAbility?)
      if battler.hasActiveAbility?(:PRANKSTER) && movedata.category==2
        movePriority += 1
      end
      if battler.hasActiveAbility?(:GALEWINGS) && movedata.type == :FLYING && battler.hp == battler.totalhp
        movePriority += 1
      end
      if battler.hasActiveAbility?(:TRIAGE) && movedata.healingMove?
        movePriority += 3
      end
    end

    priorityStr = "-" if movePriority == 0
    priorityStr = "+#{movePriority}" if movePriority > 0
    priorityStr = "#{movePriority}" if movePriority < 0
    return priorityStr
  end
  #-----------------------------------------------------------------------------
end
