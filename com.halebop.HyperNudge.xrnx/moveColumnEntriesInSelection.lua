require "util"
require "matrix"
require "NoteCell"
require "EffectCell"

local columnEntryMovedToNewLine

local function moveColumnEntriesUpForTheFirstLine(numberOfSteps)

  for i = 1, #columnMatrix do    
    for j = 1, #columnMatrix[i] do
    
      local cell = cellMatrix[i][j]
      local column = columnMatrix[i][j]
      
      if cell.isNotEmpty and (not cell.movingToNewLine) then
        cell:updateValue(column)
      end
    end
  end
end

local function firstRowOnNewLineIsEmpty()
  
  if columnEntryMovedToNewLine then
    return true
  end
  
  for j = 1, #columnMatrix[1] do
  
    if not columnMatrix[1][j].is_empty then
      return false
    end
  end
  
  return true
end

local function moveColumnEntriesUp(numberOfSteps)

  for i = 1, #columnMatrix-1 do    
    for j = 1, #columnMatrix[i] do
    
      local columnOnNewLine = columnMatrix[i][j]
      local cell = cellMatrix[i+1][j]
      local column = columnMatrix[i+1][j]
      
      if cell.movingToNewLine and columnOnNewLine.is_empty and firstRowOnNewLineIsEmpty() then
        columnEntryMovedToNewLine = true
        columnOnNewLine:copy_from(column)
        column:clear()
        cell:updateValue(columnOnNewLine)
      elseif cell.isNotEmpty and (not cell.movingToNewLine) then
        cell:updateValue(column)
      end
    end
  end
end

local function lastRowOnNewLineIsEmpty()
  
  if columnEntryMovedToNewLine then
    return true
  end
  
  for j = 1, #columnMatrix[#columnMatrix] do
  
    if not columnMatrix[#columnMatrix][j].is_empty then
      return false
    end
  end
  
  return true
end

local function moveColumnEntriesDown(numberOfSteps)

  for i = #columnMatrix, 2, -1  do    
    for j = #columnMatrix[i], 1, -1 do
    
      local columnOnNewLine = columnMatrix[i][j]
      local cell = cellMatrix[i-1][j]
      local column = columnMatrix[i-1][j]
      
      if cell.movingToNewLine and columnOnNewLine.is_empty and lastRowOnNewLineIsEmpty() then
        columnEntryMovedToNewLine = true
        columnOnNewLine:copy_from(column)
        column:clear()
        cell:updateValue(columnOnNewLine)
      elseif cell.isNotEmpty and (not cell.movingToNewLine) then
        cell:updateValue(column)
      end    
    end
  end 
end

local function moveColumnEntriesDownForTheLastLine(numberOfSteps)

  for i = #columnMatrix, 1, -1  do    
    for j = #columnMatrix[i], 1, -1 do
  
      local cell = cellMatrix[i][j]
      local column = columnMatrix[i][j]
      
      if cell.isNotEmpty and (not cell.movingToNewLine) then
        cell:updateValue(column)
      end    
    end
  end 
end

local function moveColumnEntriesInSelection(numberOfSteps)

  columnEntryMovedToNewLine = false

  if numberOfSteps < 0 then
  
    if selectionStartsOnTheFirstLine() then
      moveColumnEntriesUpForTheFirstLine(numberOfSteps)
    else
      moveColumnEntriesUp(numberOfSteps)
    end
  else
  
    if selectionEndsOnTheLastLine() then
      moveColumnEntriesDownForTheLastLine(numberOfSteps)
    else
      moveColumnEntriesDown(numberOfSteps)
    end
  end
end

function moveColumnEntriesInSelectionUpByOneLine()
  moveColumnEntriesInSelection(-256)
  return columnEntryMovedToNewLine
end

function moveColumnEntriesInSelectionUpByOneStep()
  moveColumnEntriesInSelection(-1)
  return columnEntryMovedToNewLine
end

function moveColumnEntriesInSelectionDownByOneLine()
  moveColumnEntriesInSelection(256)
  return columnEntryMovedToNewLine
end

function moveColumnEntriesInSelectionDownByOneStep()
  moveColumnEntriesInSelection(1)
  return columnEntryMovedToNewLine
end
