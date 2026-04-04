require "moveColumnEntriesInSelection"
require "selectionRange"
require "editCursor"
require "phraseNudge"

------------------------------------------------------------------------
-- Pattern Editor helpers (original)
------------------------------------------------------------------------

local function selectionIsNil()
  return renoise.song().selection_in_pattern == nil
end

local function effectColumnIsSelected()
  return renoise.song().selected_effect_column_index ~= 0
end

local function showNoteDelayColumn(trackIndex)
  local track = renoise.song():track(trackIndex)
  if (track.type == 1) then
    track.delay_column_visible = true
  end
end

local function showNoteDelayColumns()
  local selection = renoise.song().selection_in_pattern
  for trackIndex = selection.start_track, selection.end_track do
    showNoteDelayColumn(trackIndex)
  end
end

------------------------------------------------------------------------
-- Menu entries
------------------------------------------------------------------------

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:HyperNudge:Pattern Editor:Nudge Up by 1 step",
  invoke = function()
    if renoise.song().selection_in_pattern == nil and
       renoise.song().selected_effect_column_index ~= 0 then return end
    local usingEditCursor = renoise.song().selection_in_pattern == nil
    if usingEditCursor then selectEditCursorCell() end
    local empty = populateMatrixForMovingUpByOneStep()
    if not empty then
      showNoteDelayColumns()
      shrinkSelectionRangeWhenMovingUp()
      local moved = moveColumnEntriesInSelectionUpByOneStep()
      moveSelectionRangeUp(moved)
      if usingEditCursor and moved then moveEditCursorUp() end
    end
    if usingEditCursor then clearSelection() end
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:HyperNudge:Pattern Editor:Nudge Up by 1 line",
  invoke = function()
    local usingEditCursor = renoise.song().selection_in_pattern == nil
    if usingEditCursor then selectEditCursorCell() end
    local empty = populateMatrixForMovingUpByOneLine()
    if not empty then
      shrinkSelectionRangeWhenMovingUp()
      local moved = moveColumnEntriesInSelectionUpByOneLine()
      moveSelectionRangeUp(moved)
      if usingEditCursor and moved then moveEditCursorUp() end
    end
    if usingEditCursor then clearSelection() end
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:HyperNudge:Pattern Editor:Nudge Down by 1 step",
  invoke = function()
    if renoise.song().selection_in_pattern == nil and
       renoise.song().selected_effect_column_index ~= 0 then return end
    local usingEditCursor = renoise.song().selection_in_pattern == nil
    if usingEditCursor then selectEditCursorCell() end
    local empty = populateMatrixForMovingDownByOneStep()
    if not empty then
      showNoteDelayColumns()
      shrinkSelectionRangeWhenMovingDown()
      local moved = moveColumnEntriesInSelectionDownByOneStep()
      moveSelectionRangeDown(moved)
      if usingEditCursor and moved then moveEditCursorDown() end
    end
    if usingEditCursor then clearSelection() end
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:HyperNudge:Pattern Editor:Nudge Down by 1 line",
  invoke = function()
    local usingEditCursor = renoise.song().selection_in_pattern == nil
    if usingEditCursor then selectEditCursorCell() end
    local empty = populateMatrixForMovingDownByOneLine()
    if not empty then
      shrinkSelectionRangeWhenMovingDown()
      local moved = moveColumnEntriesInSelectionDownByOneLine()
      moveSelectionRangeDown(moved)
      if usingEditCursor and moved then moveEditCursorDown() end
    end
    if usingEditCursor then clearSelection() end
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:HyperNudge:Phrase Editor:Nudge Up by 1 step",
  invoke = function()
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeUpByOneStep()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:HyperNudge:Phrase Editor:Nudge Up by 1 line",
  invoke = function()
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeUpByOneLine()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:HyperNudge:Phrase Editor:Nudge Down by 1 step",
  invoke = function()
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeDownByOneStep()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:HyperNudge:Phrase Editor:Nudge Down by 1 line",
  invoke = function()
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeDownByOneLine()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:HyperNudge:Phrase Editor:Nudge All Columns Up by 1 line",
  invoke = function()
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeAllColumnsUpByOneLine()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:HyperNudge:Phrase Editor:Nudge All Columns Down by 1 line",
  invoke = function()
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeAllColumnsDownByOneLine()
  end
}

------------------------------------------------------------------------
-- Pattern Editor keybindings (original, unchanged)
------------------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:Nudge Up by 1 step",
  invoke = function(repeated)
    
    local usingEditCursor = false
    
    if selectionIsNil() and effectColumnIsSelected() then
      return
    elseif selectionIsNil() then
      usingEditCursor = true
      selectEditCursorCell()
    end
    
    local allEntriesInSelectionAreEmpty = populateMatrixForMovingUpByOneStep()
    
    if allEntriesInSelectionAreEmpty then
    
      if usingEditCursor then  
        clearSelection()
      end
    
      return
    end
    
    showNoteDelayColumns()
    shrinkSelectionRangeWhenMovingUp()     
    local columnEntryMovedToNewLine = moveColumnEntriesInSelectionUpByOneStep()
    moveSelectionRangeUp(columnEntryMovedToNewLine)

    if usingEditCursor then
      
      clearSelection()
      
      if columnEntryMovedToNewLine then
        moveEditCursorUp()
      end
    end
  end
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:Nudge Up by 1 line",
  invoke = function(repeated)
 
    local usingEditCursor = false
 
    if selectionIsNil() then
      usingEditCursor = true
      selectEditCursorCell()
    end

    local allEntriesInSelectionAreEmpty = populateMatrixForMovingUpByOneLine()
    
    if allEntriesInSelectionAreEmpty then
    
      if usingEditCursor then  
        clearSelection()
      end
    
      return
    end
    
    shrinkSelectionRangeWhenMovingUp()     
    local columnEntryMovedToNewLine = moveColumnEntriesInSelectionUpByOneLine()
    moveSelectionRangeUp(columnEntryMovedToNewLine)
    
    if usingEditCursor then
      
      clearSelection()
      
      if columnEntryMovedToNewLine then
        moveEditCursorUp()
      end
    end 
  end
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:Nudge Down by 1 step",
  invoke = function(repeated)

    local usingEditCursor = false

    if selectionIsNil() and effectColumnIsSelected() then
      return
    elseif selectionIsNil() then
      usingEditCursor = true
      selectEditCursorCell()
    end
    
    local allEntriesInSelectionAreEmpty = populateMatrixForMovingDownByOneStep()
    
    if allEntriesInSelectionAreEmpty then
    
      if usingEditCursor then  
        clearSelection()
      end
    
      return
    end
    
    showNoteDelayColumns()
    shrinkSelectionRangeWhenMovingDown()
    local columnEntryMovedToNewLine = moveColumnEntriesInSelectionDownByOneStep()
    moveSelectionRangeDown(columnEntryMovedToNewLine)
    
    if usingEditCursor then
      
      clearSelection()
      
      if columnEntryMovedToNewLine then
        moveEditCursorDown()
      end
    end
  end
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:Nudge Down by 1 line",
  invoke = function(repeated)

    local usingEditCursor = false

    if selectionIsNil() then
      usingEditCursor = true
      selectEditCursorCell()
    end
    
    local allEntriesInSelectionAreEmpty = populateMatrixForMovingDownByOneLine()

    if allEntriesInSelectionAreEmpty then
    
      if usingEditCursor then  
        clearSelection()
      end
    
      return
    end
    
    shrinkSelectionRangeWhenMovingDown()
    local columnEntryMovedToNewLine = moveColumnEntriesInSelectionDownByOneLine()
    moveSelectionRangeDown(columnEntryMovedToNewLine)
    
    if usingEditCursor then
      
      clearSelection()
      
      if columnEntryMovedToNewLine then
        moveEditCursorDown()
      end
    end
  end
}

------------------------------------------------------------------------
-- Phrase Editor keybindings (new)
------------------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Phrase Editor:Tools:Nudge Up by 1 step",
  invoke = function(repeated)
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeUpByOneStep()
  end
}

renoise.tool():add_keybinding {
  name = "Phrase Editor:Tools:Nudge Up by 1 line",
  invoke = function(repeated)
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeUpByOneLine()
  end
}

renoise.tool():add_keybinding {
  name = "Phrase Editor:Tools:Nudge Down by 1 step",
  invoke = function(repeated)
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeDownByOneStep()
  end
}

renoise.tool():add_keybinding {
  name = "Phrase Editor:Tools:Nudge Down by 1 line",
  invoke = function(repeated)
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeDownByOneLine()
  end
}

renoise.tool():add_keybinding {
  name = "Phrase Editor:Tools:Nudge All Columns Up by 1 line",
  invoke = function(repeated)
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeAllColumnsUpByOneLine()
  end
}

renoise.tool():add_keybinding {
  name = "Phrase Editor:Tools:Nudge All Columns Down by 1 line",
  invoke = function(repeated)
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeAllColumnsDownByOneLine()
  end
}

------------------------------------------------------------------------
-- MIDI mappings
------------------------------------------------------------------------

-- Accepts trigger (CC button), note-on (abs value > 0), or switch-on
local function midi_is_press(message)
  return message:is_trigger() or
         (message:is_abs_value() and message.int_value > 0) or
         (message:is_switch() and message.boolean_value)
end

renoise.tool():add_midi_mapping {
  name = "Tools:HyperNudge:Pattern Editor:Nudge Up by 1 step",
  invoke = function(message)
    if not midi_is_press(message) then return end
    if renoise.song().selection_in_pattern == nil and
       renoise.song().selected_effect_column_index ~= 0 then return end
    if renoise.song().selection_in_pattern == nil then
      selectEditCursorCell()
    end
    local empty = populateMatrixForMovingUpByOneStep()
    if not empty then
      showNoteDelayColumns()
      shrinkSelectionRangeWhenMovingUp()
      local moved = moveColumnEntriesInSelectionUpByOneStep()
      moveSelectionRangeUp(moved)
    end
    clearSelection()
  end
}

renoise.tool():add_midi_mapping {
  name = "Tools:HyperNudge:Pattern Editor:Nudge Up by 1 line",
  invoke = function(message)
    if not midi_is_press(message) then return end
    if renoise.song().selection_in_pattern == nil then
      selectEditCursorCell()
    end
    local empty = populateMatrixForMovingUpByOneLine()
    if not empty then
      shrinkSelectionRangeWhenMovingUp()
      local moved = moveColumnEntriesInSelectionUpByOneLine()
      moveSelectionRangeUp(moved)
    end
    clearSelection()
  end
}

renoise.tool():add_midi_mapping {
  name = "Tools:HyperNudge:Pattern Editor:Nudge Down by 1 step",
  invoke = function(message)
    if not midi_is_press(message) then return end
    if renoise.song().selection_in_pattern == nil and
       renoise.song().selected_effect_column_index ~= 0 then return end
    if renoise.song().selection_in_pattern == nil then
      selectEditCursorCell()
    end
    local empty = populateMatrixForMovingDownByOneStep()
    if not empty then
      showNoteDelayColumns()
      shrinkSelectionRangeWhenMovingDown()
      local moved = moveColumnEntriesInSelectionDownByOneStep()
      moveSelectionRangeDown(moved)
    end
    clearSelection()
  end
}

renoise.tool():add_midi_mapping {
  name = "Tools:HyperNudge:Pattern Editor:Nudge Down by 1 line",
  invoke = function(message)
    if not midi_is_press(message) then return end
    if renoise.song().selection_in_pattern == nil then
      selectEditCursorCell()
    end
    local empty = populateMatrixForMovingDownByOneLine()
    if not empty then
      shrinkSelectionRangeWhenMovingDown()
      local moved = moveColumnEntriesInSelectionDownByOneLine()
      moveSelectionRangeDown(moved)
    end
    clearSelection()
  end
}

renoise.tool():add_midi_mapping {
  name = "Tools:HyperNudge:Phrase Editor:Nudge Up by 1 step",
  invoke = function(message)
    if not midi_is_press(message) then return end
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeUpByOneStep()
  end
}

renoise.tool():add_midi_mapping {
  name = "Tools:HyperNudge:Phrase Editor:Nudge Up by 1 line",
  invoke = function(message)
    if not midi_is_press(message) then return end
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeUpByOneLine()
  end
}

renoise.tool():add_midi_mapping {
  name = "Tools:HyperNudge:Phrase Editor:Nudge Down by 1 step",
  invoke = function(message)
    if not midi_is_press(message) then return end
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeDownByOneStep()
  end
}

renoise.tool():add_midi_mapping {
  name = "Tools:HyperNudge:Phrase Editor:Nudge Down by 1 line",
  invoke = function(message)
    if not midi_is_press(message) then return end
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeDownByOneLine()
  end
}

renoise.tool():add_midi_mapping {
  name = "Tools:HyperNudge:Phrase Editor:Nudge All Columns Up by 1 line",
  invoke = function(message)
    if not midi_is_press(message) then return end
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeAllColumnsUpByOneLine()
  end
}

renoise.tool():add_midi_mapping {
  name = "Tools:HyperNudge:Phrase Editor:Nudge All Columns Down by 1 line",
  invoke = function(message)
    if not midi_is_press(message) then return end
    if renoise.song().selected_phrase == nil then return end
    phraseNudgeAllColumnsDownByOneLine()
  end
}
