#-------------------------------------------------------------------------------
# EBDX Mouse UI interface
#-------------------------------------------------------------------------------
module Mouse
  module UISelection
    module_function

    #---------------------------------------------------------------------------
    # Check if mouse is active
    #---------------------------------------------------------------------------
    def active?
      return Mouse.respond_to?(:active?) && Mouse.respond_to?(:click?) && Mouse.active?
    end

    #---------------------------------------------------------------------------
    # Left-click anywhere on screen (used to advance/dismiss text boxes).
    # Call it once every frame of the waiting loop so the press is tracked.
    #---------------------------------------------------------------------------
    def confirm_click?
      return active? && Mouse.click?(nil, :left)
    end

    #---------------------------------------------------------------------------
    # Find the key/index of the element the mouse is currently hovering over.
    #---------------------------------------------------------------------------
    def hovered_index(collection)
      return nil unless active?
      if collection.is_a?(Hash)
        collection.each do |key, sprite|
          next if sprite.nil?
          next if sprite.respond_to?(:disposed?) && sprite.disposed?
          next if sprite.respond_to?(:visible) && !sprite.visible
          return key if Mouse.over?(sprite)
        end
      elsif collection.is_a?(Array)
        collection.each_with_index do |sprite, idx|
          next if sprite.nil?
          next if sprite.respond_to?(:disposed?) && sprite.disposed?
          next if sprite.respond_to?(:visible) && !sprite.visible
          return idx if Mouse.over?(sprite)
        end
      end
      return nil
    end

    #---------------------------------------------------------------------------
    # Returns true only on frames where the mouse cursor actually moved.
    # Hover highlighting is gated on this so that a stationary cursor resting on
    # a button no longer overrides keyboard/gamepad navigation every frame.
    # (State is cached per frame so several callers in one frame agree.)
    #---------------------------------------------------------------------------
    def mouse_moved?
      frame = Graphics.frame_count
      if @mm_frame != frame
        @mm_frame = frame
        mx, my = Mouse.x, Mouse.y
        @mm_moved = !@mm_x.nil? && (mx != @mm_x || my != @mm_y)
        @mm_x, @mm_y = mx, my
      end
      return @mm_moved
    end

    #---------------------------------------------------------------------------
    # Check the mouse interactions for a standard UI selection menu.
    #---------------------------------------------------------------------------
    def update_menu(collection, current_index)
      return nil unless active?
      if Input.respond_to?(:scroll_v)
        scroll = Input.scroll_v
        if scroll > 0
          return [:scroll_up, nil]
        elsif scroll < 0
          return [:scroll_down, nil]
        end
      end
      return [:cancel, nil] if EliteBattle::RIGHT_CLICK_BACK_ACTION && Mouse.click?(nil, :right)
      moved = mouse_moved?
      if @pending_select
        pending, @pending_select = @pending_select, nil
        return [:select, pending] if pending == current_index
      end
      hovered = hovered_index(collection)
      if hovered
        if Mouse.click?(collection[hovered], :left)
          return [:select, hovered] if hovered == current_index
          # clicked something other than the current selection: highlight it
          # first, then confirm on the next frame
          @pending_select = hovered
          return [:highlight, hovered]
        end
        # Highlight/Hover (only when the mouse actually moved)
        return [:highlight, hovered] if moved && hovered != current_index
      end
      return nil
    end

    #---------------------------------------------------------------------------
    # Unified action helper checking both Mouse and Keyboard triggers for
    # Select, Cancel, Hover, and Scroll.
    #---------------------------------------------------------------------------
    def input_action(collection, current_index)
      if (active? && EliteBattle::RIGHT_CLICK_BACK_ACTION && Mouse.click?(nil, :right)) || Input.trigger?(Input::B)
        return [:cancel, nil]
      end
      if active? && collection
        moved = mouse_moved?
        if @pending_select
          pending, @pending_select = @pending_select, nil
          return [:select, pending] if pending == current_index
        end
        hovered = hovered_index(collection)
        if hovered
          if Mouse.click?(collection[hovered], :left)
            return [:select, hovered] if hovered == current_index
            # clicked something other than the current selection: highlight it
            # first, then confirm on the next frame
            @pending_select = hovered
            return [:highlight, hovered]
          end
          # Highlight/Hover (only when the mouse actually moved)
          return [:highlight, hovered] if moved && hovered != current_index
        end
      end
      return [:select, current_index] if Input.trigger?(Input::C)
      if active? && Input.respond_to?(:scroll_v)
        scroll = Input.scroll_v
        if scroll > 0
          return [:scroll_up, nil]
        elsif scroll < 0
          return [:scroll_down, nil]
        end
      end
      return [nil, nil]
    end
  end
end
