local function numberOfNoteColumns(i)
  return renoise.song():track(i).visible_note_columns
end

local function columnIndex()
  
  if renoise.song().selected_effect_column_index == 0 then
    return renoise.song().selected_note_column_index
  else
    return numberOfNoteColumns(renoise.song().selected_track_index) + renoise.song().selected_effect_column_index
  end
end

function selectEditCursorCell()
  
  local selectionInPattern = {}
  selectionInPattern["end_column"] = columnIndex()
  selectionInPattern["end_line"] = renoise.song().transport.edit_pos.line
  selectionInPattern["end_track"] = renoise.song().selected_track_index
  selectionInPattern["start_column"] = columnIndex()
  selectionInPattern["start_line"] = renoise.song().transport.edit_pos.line
  selectionInPattern["start_track"] = renoise.song().selected_track_index
  renoise.song().selection_in_pattern = selectionInPattern
end

function moveEditCursorUp()

  local editPosition = renoise.song().transport.edit_pos
  editPosition.line = editPosition.line-1
  renoise.song().transport.edit_pos = editPosition
end

function moveEditCursorDown()

  local editPosition = renoise.song().transport.edit_pos
  editPosition.line = editPosition.line+1
  renoise.song().transport.edit_pos = editPosition
end

function clearSelection()
  renoise.song().selection_in_pattern = nil
end
