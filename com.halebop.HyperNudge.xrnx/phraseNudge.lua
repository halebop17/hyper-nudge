-- phraseNudge.lua
-- Handles nudge operations in the Phrase Editor.
-- Notes are moved with full sub-column preservation (volume, pan, delay, instrument).
-- Effects are moved by 1 line only (no step/delay concept in effect columns).
-- When no selection is active, operates on the cursor column at the cursor line.
-- When a selection is active (selection_in_phrase), operates on all columns in range.
-- Phrases are treated as loops: nudging past the first/last line wraps around.

require "util"

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------

local function song()
  return renoise.song()
end

local function getPhrase()
  return song().selected_phrase
end

-- Copy all sub-columns from one note column to another
local function copyNoteColumn(src, dst)
  dst:copy_from(src)
end

-- Copy an effect column
local function copyEffectColumn(src, dst)
  dst:copy_from(src)
end

-- Wraps a line index around phrase boundaries (1-based, inclusive)
local function wrapLine(lineIdx, numLines)
  return ((lineIdx - 1) % numLines) + 1
end

------------------------------------------------------------------------
-- Single-cursor nudge (no selection active)
------------------------------------------------------------------------

-- Move the note column at cursor up or down by one line, with wrap-around.
-- direction: -1 = up, +1 = down
local function nudgeCursorNoteByOneLine(direction)

  local phrase    = getPhrase()
  local lineIdx   = song().selected_phrase_line_index
  local colIdx    = song().selected_phrase_note_column_index  -- FIXED: phrase-specific API

  if colIdx == 0 then return end  -- cursor is on an effect column

  local targetIdx = wrapLine(lineIdx + direction, phrase.number_of_lines)

  local srcCol = phrase:line(lineIdx).note_columns[colIdx]
  local dstCol = phrase:line(targetIdx).note_columns[colIdx]

  if srcCol.is_empty then return end
  if not dstCol.is_empty then return end

  copyNoteColumn(srcCol, dstCol)
  srcCol:clear()

  song().selected_phrase_line_index = targetIdx
end

-- Move the effect column at cursor up or down by one line, with wrap-around.
local function nudgeCursorEffectByOneLine(direction)

  local phrase  = getPhrase()
  local lineIdx = song().selected_phrase_line_index
  local fxIdx   = song().selected_phrase_effect_column_index  -- FIXED: phrase-specific API

  if fxIdx == 0 then return end  -- cursor is on a note column

  local targetIdx = wrapLine(lineIdx + direction, phrase.number_of_lines)

  local srcCol = phrase:line(lineIdx).effect_columns[fxIdx]
  local dstCol = phrase:line(targetIdx).effect_columns[fxIdx]

  if srcCol.is_empty then return end
  if not dstCol.is_empty then return end

  copyEffectColumn(srcCol, dstCol)
  srcCol:clear()

  song().selected_phrase_line_index = targetIdx
end

-- Unified cursor nudge dispatcher
local function nudgeCursorByOneLine(direction)

  local phrase = getPhrase()
  if not phrase then return end

  if song().selected_phrase_effect_column_index ~= 0 then  -- FIXED: phrase-specific API
    nudgeCursorEffectByOneLine(direction)
  else
    nudgeCursorNoteByOneLine(direction)
  end
end

------------------------------------------------------------------------
-- Selection-range line nudge
------------------------------------------------------------------------

-- Returns the selection table or nil if no selection.
local function getPhraseSelection()
  return song().selection_in_phrase
end

-- Nudge all columns in the phrase selection up or down by one line, with wrap-around.
-- When moving up:   process lines top-to-bottom so we don't clobber src data
-- When moving down: process lines bottom-to-top
local function nudgeSelectionByOneLine(direction)

  local phrase = getPhrase()
  if not phrase then return end

  local sel = getPhraseSelection()
  if sel == nil then
    nudgeCursorByOneLine(direction)
    return
  end

  local numLines  = phrase.number_of_lines
  local startLine = sel.start_line
  local endLine   = sel.end_line
  local startCol  = sel.start_column
  local endCol    = sel.end_column

  local visNoteColumns = phrase.visible_note_columns

  -- Determine iteration order (process in movement direction to avoid clobbering)
  local lineFrom, lineTo, lineStep
  if direction == -1 then
    lineFrom, lineTo, lineStep = startLine, endLine, 1
  else
    lineFrom, lineTo, lineStep = endLine, startLine, -1
  end

  local lineIdx = lineFrom
  while true do

    local targetIdx = wrapLine(lineIdx + direction, numLines)

    for colIdx = startCol, endCol do

      if colIdx <= visNoteColumns then
        local srcCol = phrase:line(lineIdx).note_columns[colIdx]
        local dstCol = phrase:line(targetIdx).note_columns[colIdx]

        if not srcCol.is_empty and dstCol.is_empty then
          copyNoteColumn(srcCol, dstCol)
          srcCol:clear()
        end

      else
        local fxIdx  = colIdx - visNoteColumns
        local srcCol = phrase:line(lineIdx).effect_columns[fxIdx]
        local dstCol = phrase:line(targetIdx).effect_columns[fxIdx]

        if not srcCol.is_empty and dstCol.is_empty then
          copyEffectColumn(srcCol, dstCol)
          srcCol:clear()
        end
      end
    end

    if lineIdx == lineTo then break end
    lineIdx = lineIdx + lineStep
  end

  -- Shift the selection itself, wrapping around phrase boundaries
  song().selection_in_phrase = {
    start_line   = wrapLine(sel.start_line + direction, numLines),
    end_line     = wrapLine(sel.end_line   + direction, numLines),
    start_column = sel.start_column,
    end_column   = sel.end_column,
  }
end

------------------------------------------------------------------------
-- All-columns line nudge (cursor line or full selection, all columns)
------------------------------------------------------------------------

-- Build a synthetic selection covering all columns on the cursor line (or the
-- existing selection's line range), then delegate to nudgeSelectionByOneLine.
local function nudgeAllColumnsByOneLine(direction)

  local phrase = getPhrase()
  if not phrase then return end

  local totalCols = phrase.visible_note_columns + phrase.visible_effect_columns
  if totalCols == 0 then return end

  local sel = getPhraseSelection()
  local startLine, endLine

  if sel ~= nil then
    startLine = sel.start_line
    endLine   = sel.end_line
  else
    local lineIdx = song().selected_phrase_line_index
    startLine = lineIdx
    endLine   = lineIdx
  end

  -- Temporarily set a full-width selection, nudge, then restore or clear
  song().selection_in_phrase = {
    start_line   = startLine,
    end_line     = endLine,
    start_column = 1,
    end_column   = totalCols,
  }

  nudgeSelectionByOneLine(direction)

  -- After nudging, re-apply the original selection (or clear if there was none)
  if sel ~= nil then
    -- Shift it the same way nudgeSelectionByOneLine did
    song().selection_in_phrase = {
      start_line   = wrapLine(sel.start_line + direction, phrase.number_of_lines),
      end_line     = wrapLine(sel.end_line   + direction, phrase.number_of_lines),
      start_column = sel.start_column,
      end_column   = sel.end_column,
    }
  else
    song().selection_in_phrase = nil
  end
end

------------------------------------------------------------------------
-- Step nudge (cursor, with wrap-around)
------------------------------------------------------------------------

-- Adjust delay_value by ±1. When delay crosses 0 or 255, the note wraps to
-- the adjacent line (and wraps around phrase boundaries).
local function nudgeCursorNoteByOneStep(direction)

  local phrase  = getPhrase()
  if not phrase then return end

  local lineIdx = song().selected_phrase_line_index
  local colIdx  = song().selected_phrase_note_column_index  -- FIXED: phrase-specific API
  if colIdx == 0 then return end

  local noteCol = phrase:line(lineIdx).note_columns[colIdx]
  if noteCol.is_empty then return end

  phrase.delay_column_visible = true

  local delay    = noteCol.delay_value
  local newDelay = delay + direction

  if newDelay < 0 then
    local targetIdx = wrapLine(lineIdx - 1, phrase.number_of_lines)
    local dstCol    = phrase:line(targetIdx).note_columns[colIdx]
    if not dstCol.is_empty then return end
    copyNoteColumn(noteCol, dstCol)
    noteCol:clear()
    dstCol.delay_value = newDelay + 256
    song().selected_phrase_line_index = targetIdx

  elseif newDelay > 255 then
    local targetIdx = wrapLine(lineIdx + 1, phrase.number_of_lines)
    local dstCol    = phrase:line(targetIdx).note_columns[colIdx]
    if not dstCol.is_empty then return end
    copyNoteColumn(noteCol, dstCol)
    noteCol:clear()
    dstCol.delay_value = newDelay - 256
    song().selected_phrase_line_index = targetIdx

  else
    noteCol.delay_value = newDelay
  end
end

------------------------------------------------------------------------
-- Step nudge with selection (all note columns in selection, with wrap-around)
------------------------------------------------------------------------

local function nudgeSelectionByOneStep(direction)

  local phrase = getPhrase()
  if not phrase then return end

  local sel = getPhraseSelection()
  if sel == nil then
    nudgeCursorNoteByOneStep(direction)
    return
  end

  phrase.delay_column_visible = true

  local numLines       = phrase.number_of_lines
  local visNoteColumns = phrase.visible_note_columns
  local startLine      = sel.start_line
  local endLine        = sel.end_line
  local startCol       = sel.start_column
  local endCol         = math.min(sel.end_column, visNoteColumns)  -- only note columns have delay

  if startCol > visNoteColumns then return end  -- selection covers only effect columns

  -- When nudging up (delay decreases), process top-to-bottom so notes that wrap
  -- upward land on lines we have already processed.
  -- When nudging down (delay increases), process bottom-to-top for the same reason.
  local lineFrom, lineTo, lineStep
  if direction == -1 then
    lineFrom, lineTo, lineStep = startLine, endLine, 1
  else
    lineFrom, lineTo, lineStep = endLine, startLine, -1
  end

  local lineIdx = lineFrom
  while true do

    for colIdx = startCol, endCol do

      local noteCol = phrase:line(lineIdx).note_columns[colIdx]
      if not noteCol.is_empty then

        local delay    = noteCol.delay_value
        local newDelay = delay + direction

        if newDelay < 0 then
          local targetIdx = wrapLine(lineIdx - 1, numLines)
          local dstCol    = phrase:line(targetIdx).note_columns[colIdx]
          if dstCol.is_empty then
            copyNoteColumn(noteCol, dstCol)
            noteCol:clear()
            dstCol.delay_value = newDelay + 256
          end

        elseif newDelay > 255 then
          local targetIdx = wrapLine(lineIdx + 1, numLines)
          local dstCol    = phrase:line(targetIdx).note_columns[colIdx]
          if dstCol.is_empty then
            copyNoteColumn(noteCol, dstCol)
            noteCol:clear()
            dstCol.delay_value = newDelay - 256
          end

        else
          noteCol.delay_value = newDelay
        end
      end
    end

    if lineIdx == lineTo then break end
    lineIdx = lineIdx + lineStep
  end
end

------------------------------------------------------------------------
-- Public API (called from main.lua)
------------------------------------------------------------------------

function phraseNudgeUpByOneLine()
  nudgeSelectionByOneLine(-1)
end

function phraseNudgeDownByOneLine()
  nudgeSelectionByOneLine(1)
end

function phraseNudgeAllColumnsUpByOneLine()
  nudgeAllColumnsByOneLine(-1)
end

function phraseNudgeAllColumnsDownByOneLine()
  nudgeAllColumnsByOneLine(1)
end

function phraseNudgeUpByOneStep()
  nudgeSelectionByOneStep(-1)
end

function phraseNudgeDownByOneStep()
  nudgeSelectionByOneStep(1)
end
