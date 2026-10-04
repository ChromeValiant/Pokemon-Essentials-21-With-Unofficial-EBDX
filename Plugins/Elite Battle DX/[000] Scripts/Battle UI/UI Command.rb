#===============================================================================
#  Command Menu functionality part
#===============================================================================
class Battle::Scene
  #-----------------------------------------------------------------------------
  #  command menu override
  #-----------------------------------------------------------------------------
  alias pbCommandMenu_ebdx pbCommandMenu unless self.method_defined?(:pbCommandMenu_ebdx)
  def pbCommandMenu(*args)
    @orgPos = [@vector.x, @vector.y, @vector.angle, @vector.scale, @vector.zoom1] if @orgPos.nil?
    @idleTimer = 0 if @idleTimer < 0
    return pbCommandMenu_ebdx(*args)
  end
  #-----------------------------------------------------------------------------
  #  main command menu function
  #-----------------------------------------------------------------------------
  alias pbCommandMenuEx_ebdx pbCommandMenuEx unless self.method_defined?(:pbCommandMenuEx_ebdx)
  def pbCommandMenuEx(idxBattler, texts, mode = 0)
    self.clearMessageWindow
    # set starting variables
    @ret = 0; @vector.reset; @inCMx = true
    @commandWindow.refreshCommands(idxBattler)
    # show command window
    #name = (@safaribattle) ? $player.name : @battle.battlers[idxBattler].name
    pbSEPlay("EBDX/SE_Zoom4", 50)
    @commandWindow.showPlay
    @sprites["dataBox_#{idxBattler}"].selected = true
	# debug switch to Fight when last command was CALL
	if @commandWindow.index == 3
		@commandWindow.index = 0
	end
	# debug switch to moves when choosen items before
	if (@commandWindow.index == 1 || @commandWindow.index == 2)
		@commandWindow.index = 0
	end
	#	
    loop do
      oldIndex = @commandWindow.index
      # main update
      self.updateWindow(@commandWindow)
      # Mouse and keyboard input action support
      buttons = {}
      for i in 0...@commandWindow.indexes.length
        buttons[i] = @commandWindow.sprites["b#{i}"]
      end
      action, val = Mouse::UISelection.input_action(buttons, @commandWindow.index)
      case action
      when :highlight
        @commandWindow.index = val
      when :select
        if @commandWindow.index == 4 && $DEBUG
          ebsDebugMenu
        else
          pbSEPlay("EBDX/SE_Select2")
          @ret = @commandWindow.indexes[@commandWindow.index]
          @inCMx = false if @battle.doublebattle? && @ret > 0
          @lastcmd[idxBattler] = @ret
          break
        end
      when :cancel
        if idxBattler > 0 && @lastcmd[0] != 2
          pbSEPlay("EBDX/SE_Select2")
          @ret = -1
          break
        end
      end
      # Update selected command
      if Input.trigger?(Input::LEFT)
        @commandWindow.index = (@commandWindow.index > 0) ? (@commandWindow.index - 1) : (@commandWindow.indexes.length - 1)
      elsif Input.trigger?(Input::RIGHT)
        @commandWindow.index = (@commandWindow.index < @commandWindow.indexes.length - 1) ? (@commandWindow.index + 1) : 0
      end
      # play SE
      pbSEPlay("EBDX/SE_Select1") if @commandWindow.index != oldIndex
      if Input.trigger?(Input::F9) && $DEBUG                                 # Debug menu
        pbPlayDecisionSE
        ret = -2
        break
      end
    end
    # hide command window
    @commandWindow.hidePlay
    # reset vector
    if @ret > 0
      @vector.set(EliteBattle.get_vector(:MAIN, @battle))
      @vector.inc = 0.2
    end
    # unselect databoxes
    self.pbDeselectAll
    # return output
    return @ret
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Command Menu (Next Generation)
#  UI ovarhaul
#===============================================================================
class CommandWindowEBDX
  attr_accessor :index
  attr_accessor :overlay
  attr_accessor :backdrop
  attr_accessor :coolDown
  attr_reader :indexes
  attr_reader :sprites
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
  def initialize(viewport = nil, battle = nil, scene = nil, safari = false)
    @viewport = viewport
    @battle = battle
    @scene = scene
    @safaribattle = safari
    @index = 0
    @oldindex = 0
    @coolDown = 0
    @over = false
    @path = "Graphics/EBDX/Pictures/UI/"
    @sprites = {}
    @indexes = []

    self.applyMetrics

    @btnCmd = pbBitmap(@path+@cmdImg)
    @btnEmp = pbBitmap(@path+@empImg)

    @sprites["sel"] = SpriteSheet.new(@viewport,4)
    @sprites["sel"].setBitmap(pbSelBitmap(@path+@selImg,Rect.new(0,0,92,38)))
    @sprites["sel"].speed = 4
    @sprites["sel"].ox = @sprites["sel"].src_rect.width/2
    @sprites["sel"].oy = @sprites["sel"].src_rect.height/2
    @sprites["sel"].z = 99
    @sprites["sel"].visible = false

    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].create_rect(@viewport.width,40,Color.new(0,0,0,150))
    @sprites["bg"].bitmap = pbBitmap(@path+@barImg) if !@barImg.nil?
    @sprites["bg"].y = @viewport.height
    self.update
  end
  #-----------------------------------------------------------------------------
  #  PBS data
  #-----------------------------------------------------------------------------
  def applyMetrics
    # sets default values
    @cmdImg = "btnCmd"
    @empImg = "btnEmpty"
    @selImg = "cmdSel"
    @parImg = "partyLine"
    @barImg = nil
    # looks up next cached metrics first
    d1 = EliteBattle.get(:nextUI)
    d1 = d1[:COMMANDMENU] if !d1.nil? && d1.has_key?(:COMMANDMENU)
    # looks up globally defined settings
    d2 = EliteBattle.get_data(:COMMANDMENU, :Metrics, :METRICS)
    # looks up globally defined settings
    d7 = EliteBattle.get_map_data(:COMMANDMENU_METRICS)
    # look up trainer specific metrics
    d6 = @battle.opponent ? EliteBattle.get_trainer_data(@battle.opponent[0].trainer_type, :COMMANDMENU_METRICS, @battle.opponent[0]) : nil
    # looks up species specific metrics
    d5 = !@battle.opponent ? EliteBattle.get_data(@battle.battlers[1].species, :Species, :COMMANDMENU_METRICS, (@battle.battlers[1].form rescue 0)) : nil
    # proceeds with parameter definition if available
    for data in [d2, d7, d6, d5, d1]
      if !data.nil?
        # applies a set of predefined keys
        @cmdImg = data[:BUTTONGRAPHIC] if data.has_key?(:BUTTONGRAPHIC) && data[:BUTTONGRAPHIC].is_a?(String)
        @selImg = data[:SELECTORGRAPHIC] if data.has_key?(:SELECTORGRAPHIC) && data[:SELECTORGRAPHIC].is_a?(String)
        @barImg = data[:BARGRAPHIC] if data.has_key?(:BARGRAPHIC) && data[:BARGRAPHIC].is_a?(String)
        @parImg = data[:PARTYLINEGRAPHIC] if data.has_key?(:PARTYLINEGRAPHIC) && data[:PARTYLINEGRAPHIC].is_a?(String)
      end
    end
  end
  #-----------------------------------------------------------------------------
  #  re-draw command menu
  #-----------------------------------------------------------------------------
  def refreshCommands(index)
    poke = @battle.battlers[index]
    cmds = self.compileCommands(index)
    h = @btnCmd.height/5
    w = @btnCmd.width/2
    for i in 0...cmds.length
      @sprites["b#{i}"] = Sprite.new(@viewport)
      @sprites["b#{i}"].bitmap = Bitmap.new(@btnEmp.width*2,@btnEmp.height)
      @sprites["b#{i}"].src_rect.width /= 2
      @sprites["b#{i}"].ox = @sprites["b#{i}"].src_rect.width/2
      @sprites["b#{i}"].oy = @sprites["b#{i}"].src_rect.height/2
      pbSetSmallFont(@sprites["b#{i}"].bitmap)
      x = (@safaribattle || (poke.shadowPokemon? && poke.inHyperMode?) || i > 3) ? w : 0
      for j in 0...2
        @sprites["b#{i}"].bitmap.blt(j*@btnEmp.width,0,@btnEmp,@btnEmp.rect)
        @sprites["b#{i}"].bitmap.blt(j*@btnEmp.width+2,0,@btnCmd,Rect.new(x,h*i,w,h)) if j > 0
        c = (j > 0) ? @btnCmd.get_pixel(x+8,h*i+8).darken(0.6) : Color.new(51,51,51)
        pbDrawOutlineText(@sprites["b#{i}"].bitmap,@btnEmp.width*j,11,@btnEmp.width,h,cmds[i],Color.white,c,1)
      end
      @sprites["b#{i}"].x = (@viewport.width/(cmds.length + 1))*(i+1)
      @sprites["b#{i}"].y = @viewport.height - 36 + 80
    end
    @sprites["bg"].y = @viewport.height + 40
    self.drawLineups
  end
  #-----------------------------------------------------------------------------
  #  party lineups shown in the bottom corners while the command menu is up
  #  (player party: bottom right, opponent trainer party: bottom left)
  #-----------------------------------------------------------------------------
  def drawLineups
    # remove previous lineup sprites
    for key in @sprites.keys.select { |k| k.to_s.start_with?("lineup") }
      @sprites[key].dispose
      @sprites.delete(key)
    end
    @lineups = []
    @lineOff = 1.0   # 1 = fully hidden (off screen), 0 = fully shown
    return if @safaribattle
    bar_bmp = pbBitmap(@path + "partyBar")
    balls_bmp = pbBitmap(@path + "partyBalls")
    num = Battle::Scene::NUM_BALLS
    bs = balls_bmp.height
    barY = @viewport.height - 74
    for side in [0, 1]
      next if side == 1 && !@battle.opponent   # wild battle: no opponent party
      party = @battle.pbParty(side).clone
      (num - party.length).times { party.push(nil) }
      party = party[0, num]
      party.reverse! if side == 1
      left = (side == 0) ? @viewport.width - bar_bmp.width : 0
      dir  = (side == 0) ? 1 : -1
      key = "lineup#{side}"
      @sprites[key] = Sprite.new(@viewport)
      @sprites[key].bitmap = bar_bmp.clone
      @sprites[key].mirror = (side == 0)
      @sprites[key].z = 10
      @sprites[key].y = barY
      @lineups.push([@sprites[key], left, dir])
      for k in 0...num
        pty = party[k]
        if pty.nil?
          pin = 3
        elsif pty.hp < 1 || pty.egg?
          pin = 2
        elsif EliteBattle.ShowStatusIcon(pty.status)
          pin = 1
        else
          pin = 0
        end
        ball = Sprite.new(@viewport)
        ball.bitmap = Bitmap.new(bs, bs)
        ball.bitmap.blt(0, 0, balls_bmp, Rect.new(bs*pin, 0, bs, bs))
        ball.z = 11
        ball.y = barY - 12
        @sprites["#{key}_#{k}"] = ball
        @lineups.push([ball, left + (side == 0 ? 26 : 12) + 24*k, dir])
      end
    end
    bar_bmp.dispose
    balls_bmp.dispose
    @lineW = @viewport.width/2
    self.positionLineups
  end
  def positionLineups
    return if @lineups.nil?
    for spr, base, dir in @lineups
      spr.x = base + dir * (@lineOff * 200)
    end
  end
  #-----------------------------------------------------------------------------
  #  compile command menu
  #-----------------------------------------------------------------------------
  def compileCommands(index)
    cmd = []
    @indexes = []
    poke = @battle.battlers[index]
    # returns indexes and commands for Safari Battles
    if @safaribattle
      @indexes = [0,1,2,3]
      return [_INTL("BALL"), _INTL("BAIT"), _INTL("ROCK"), _INTL("RUN")]
    end
    # looks up cached metrics
    d1 = EliteBattle.get(:nextUI)
    d1 = d1.has_key?(:BATTLE_COMMANDS) ? d1[:BATTLE_COMMANDS] : nil if !d1.nil?
    # looks up globally defined settings
    d1 = EliteBattle.get_data(:BATTLE_COMMANDS, :Metrics, :METRICS) if d1.nil?
    # array containing the default commands
    default = [_INTL("FIGHT"), _INTL("BAG"), _INTL("PARTY"), _INTL("RUN")]
    default.push(_INTL("DEBUG")) if $DEBUG && default.length == 4 && EliteBattle::SHOW_DEBUG_FEATURES
    for i in 0...default.length
      val = default[i]; val = _INTL("CALL") if default[i] == _INTL("RUN") && (poke.shadowPokemon?) && @battle.trainerBattle? # || poke.inHyperMode? 
      if !d1.nil?
        if d1.include?(default[i])
          @indexes.push(i); cmd.push(val)
        end
        next
      end
      cmd.push(val); @indexes.push(i)
    end
    return cmd
  end
  #-----------------------------------------------------------------------------
  #  visibility functions
  #-----------------------------------------------------------------------------
  def visible; end; def visible=(val); end
  def disposed?; end
  def dispose
    @btnCmd.dispose
    @btnEmp.dispose
    pbDisposeSpriteHash(@sprites)
  end
  def color; end; def color=(val); end
  def shiftMode=(val); end
  #-----------------------------------------------------------------------------
  #  show command menu animation
  #-----------------------------------------------------------------------------
  def show
    @sprites["sel"].visible = false
    @sprites["bg"].y -= @sprites["bg"].bitmap.height/4
    if @lineups
      @lineOff = [@lineOff - 1.0/8, 0].max
      self.positionLineups
    end
    for i in 0...@indexes.length
      next if !@sprites["b#{i}"]
      @sprites["b#{i}"].y -= 10
    end
  end
  def showPlay
    8.times do
      self.show; @scene.wait(1, true)
    end
  end
  #-----------------------------------------------------------------------------
  #  hide command menu animation
  #-----------------------------------------------------------------------------
  def hide(skip = false)
    return if skip
    @sprites["sel"].visible = false
    @sprites["bg"].y += @sprites["bg"].bitmap.height/4
    if @lineups
      @lineOff = [@lineOff + 1.0/8, 1].min
      self.positionLineups
    end
    for i in 0...@indexes.length
      next if !@sprites["b#{i}"]
      @sprites["b#{i}"].y += 10
    end
  end
  def hidePlay
    8.times do
      self.hide; @scene.wait(1, true)
    end
  end
  #-----------------------------------------------------------------------------
  #  update command menu
  #-----------------------------------------------------------------------------
  def update
    # animation for when the index changes
    for i in 0...@indexes.length
      next if !@sprites["b#{i}"]
      if i == @index
        @sprites["b#{i}"].src_rect.y = -4 if @sprites["b#{i}"].src_rect.x == 0
        @sprites["b#{i}"].src_rect.x = @sprites["b#{i}"].src_rect.width
      else
        @sprites["b#{i}"].src_rect.x = 0
      end
      @sprites["b#{i}"].src_rect.y += 1 if @sprites["b#{i}"].src_rect.y < 0
    end
    return if !@sprites["b#{@index}"]
    @sprites["sel"].visible = true
    @sprites["sel"].x = @sprites["b#{@index}"].x
    @sprites["sel"].y = @sprites["b#{@index}"].y - 2
    @sprites["sel"].update
  end
  #-----------------------------------------------------------------------------
end
