require "util"

local selection
local pattern

cellMatrix = {}
columnMatrix = {}

local allEntriesInSelectionAreEmpty

local function getFirstColumnIndex(trackIndex)

    if trackIndex == selection.start_track then
      return selection.start_column
    else
      return 1
    end
end

local function numberOfNoteColumns(trackIndex)
  return renoise.song():track(trackIndex).visible_note_columns
end

local function numberOfEffectColumns(trackIndex)
  return renoise.song():track(trackIndex).visible_effect_columns
end

local function getLastColumnIndex(trackIndex)

    if trackIndex == selection.end_track then
      return selection.end_column
    else
      return numberOfNoteColumns(trackIndex) + numberOfEffectColumns(trackIndex)
    end  
end

local function isNoteColumn(trackIndex, columnIndex)
  return columnIndex < numberOfNoteColumns(trackIndex) + 1
end

local function populateMatrixForMovingUp(numberOfSteps)

  cellMatrix = {}
  columnMatrix = {}

  local i = 1
  local firstIndex = getFirstIndexWhenMovingUp()
  for lineIndex = firstIndex, selection.end_line do
            
    cellMatrix[i] = {}
    columnMatrix[i] = {}
      
    local j = 1  
    for trackIndex = selection.start_track, selection.end_track do
    
      local line = pattern:track(trackIndex):line(lineIndex)

      local firstColumnIndex = getFirstColumnIndex(trackIndex)
      local lastColumnIndex = getLastColumnIndex(trackIndex)
      for columnIndex = firstColumnIndex, lastColumnIndex do
      
        if isNoteColumn(trackIndex, columnIndex) then

          local noteColumn = line:note_column(columnIndex)
          columnMatrix[i][j] = noteColumn
          
          if not noteColumn.is_empty and noteColumn.is_selected then
            allEntriesInSelectionAreEmpty = false
          end
          
          local noteCell = NoteCell:new(trackIndex, lineIndex, columnIndex, noteColumn, numberOfSteps)
          cellMatrix[i][j] = noteCell
          
        else
        
          local effectColumn = line:effect_column(columnIndex-numberOfNoteColumns(trackIndex))
          columnMatrix[i][j] = effectColumn
          
          if not effectColumn.is_empty and effectColumn.is_selected then
            allEntriesInSelectionAreEmpty = false
          end
          
          local effectCell = EffectCell:new(trackIndex, lineIndex, columnIndex, effectColumn, numberOfSteps) 
          cellMatrix[i][j] = effectCell
        end

        j = j + 1
      end
    end

    i = i + 1
  end
end

local function populateMatrixForMovingDown(numberOfSteps)

  cellMatrix = {}
  columnMatrix = {}

  local i = 1  
  local lastIndex = getLastIndexWhenMovingDown()
  for lineIndex = selection.start_line, lastIndex do
      
    cellMatrix[i] = {}
    columnMatrix[i] = {}
      
    local j = 1  
    for trackIndex = selection.start_track, selection.end_track do
      
      local line = pattern:track(trackIndex):line(lineIndex)
      
      local firstColumnIndex = getFirstColumnIndex(trackIndex)
      local lastColumnIndex = getLastColumnIndex(trackIndex)
      for columnIndex = firstColumnIndex, lastColumnIndex do
      
        if isNoteColumn(trackIndex, columnIndex) then

          local noteColumn = line:note_column(columnIndex)
          columnMatrix[i][j] = noteColumn
          
          if not noteColumn.is_empty and noteColumn.is_selected then
            allEntriesInSelectionAreEmpty = false
          end
          
          local noteCell = NoteCell:new(trackIndex, lineIndex, columnIndex, noteColumn, numberOfSteps)
          cellMatrix[i][j] = noteCell
          
        else
        
          local effectColumn = line:effect_column(columnIndex-numberOfNoteColumns(trackIndex))
          columnMatrix[i][j] = effectColumn
          
          if not effectColumn.is_empty and effectColumn.is_selected then
            allEntriesInSelectionAreEmpty = false
          end
          
          local effectCell = EffectCell:new(trackIndex, lineIndex, columnIndex, effectColumn, numberOfSteps) 
          cellMatrix[i][j] = effectCell
        end

        j = j + 1
      end
    end

    i = i + 1
  end
end

local function populateMatrix(numberOfSteps)
  
  selection = renoise.song().selection_in_pattern
  pattern = renoise.song().selected_pattern
  
  allEntriesInSelectionAreEmpty = true

  if numberOfSteps < 0 then
    populateMatrixForMovingUp(numberOfSteps)
  else
    populateMatrixForMovingDown(numberOfSteps)
  end
end

function populateMatrixForMovingUpByOneLine()
  populateMatrix(-256)
  return allEntriesInSelectionAreEmpty
end

function populateMatrixForMovingUpByOneStep()
  populateMatrix(-1)
  return allEntriesInSelectionAreEmpty
end

function populateMatrixForMovingDownByOneLine()
  populateMatrix(256)
  return allEntriesInSelectionAreEmpty
end

function populateMatrixForMovingDownByOneStep()
  populateMatrix(1)
  return allEntriesInSelectionAreEmpty
end
