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
      return defined?(Mouse) && Mouse.active?
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
      hovered = hovered_index(collection)
      if hovered
        return [:select, hovered] if Mouse.click?(collection[hovered], :left)
        # 5. Highlight/Hover
        return [:highlight, hovered] if hovered != current_index
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
        hovered = hovered_index(collection)
        if hovered
          return [:select, hovered] if Mouse.click?(collection[hovered], :left)
          return [:highlight, hovered] if hovered != current_index
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
