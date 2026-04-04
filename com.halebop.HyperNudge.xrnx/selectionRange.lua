require "matrix"
require "util"

local function topRowShouldMoveUp()

  if selectionStartsOnTheFirstLine() then
    return false
  end
 
  for j = 1, #columnMatrix[1] do
  
    if not columnMatrix[1][j].is_empty then
      return true
    end
  end
  
  return false
end

local function bottomRowShouldMoveUp()

  for j = 1, #columnMatrix[#columnMatrix] do
  
    if not columnMatrix[#columnMatrix][j].is_empty then
      return false
    end
  end
  
  return true
end

local function topRowShouldMoveDown()

  for j = 1, #columnMatrix[1] do
  
    if not columnMatrix[1][j].is_empty then
      return false
    end
  end
  
  return true
end

local function bottomRowShouldMoveDown()

  if selectionEndsOnTheLastLine() then
    return false
  end

  for j = 1, #columnMatrix[#columnMatrix] do
  
    if not columnMatrix[#columnMatrix][j].is_empty then
      return true
    end
  end
  
  return false
end

function moveSelectionRangeUp(columnEntryMovedToNewLine)

  local selection = renoise.song().selection_in_pattern

  if topRowShouldMoveUp() and columnEntryMovedToNewLine then
    selection.start_line = selection.start_line - 1
  end

  if bottomRowShouldMoveUp() then
    selection.end_line = selection.end_line - 1
  end 

  renoise.song().selection_in_pattern = selection
end

function moveSelectionRangeDown(columnEntryMovedToNewLine)

  local selection = renoise.song().selection_in_pattern

  if topRowShouldMoveDown() then
    selection.start_line = selection.start_line + 1
  end

  if bottomRowShouldMoveDown() and columnEntryMovedToNewLine then
    selection.end_line = selection.end_line + 1
  end

  renoise.song().selection_in_pattern = selection
end

local function getFirstIndexOfColumnMatrix()

  if selectionStartsOnTheFirstLine() then
    return 1
  else
    return 2
  end
end

local function getNewSelectionStartLineWhenMovingUp()

  local selection = renoise.song().selection_in_pattern
  local firstIndex = getFirstIndexWhenMovingUp()
  
  local firstIndexOfColumnMatrix = getFirstIndexOfColumnMatrix()

  for i = firstIndexOfColumnMatrix, #columnMatrix do    
    for j = 1, #columnMatrix[i] do
    
      if not columnMatrix[i][j].is_empty then
      
        for rowIndex = 1, i-2 do
          table.remove(cellMatrix, 1)
          table.remove(columnMatrix, 1)
        end
        
        return firstIndex + i - 1
      end
    end
  end
  
  return selection.start_line
end

local function getNewSelectionEndLineWhenMovingUp()

  local selection = renoise.song().selection_in_pattern
  local numberOfLinesInColumnMatrix = #columnMatrix
            
  for i = #columnMatrix, 1, -1  do    
    for j = #columnMatrix[i], 1, -1 do
    
      if not columnMatrix[i][j].is_empty then

        for rowIndex = #columnMatrix, i+1, -1  do        
          table.remove(columnMatrix)
          table.remove(cellMatrix)
        end
      
        return selection.end_line - (numberOfLinesInColumnMatrix - i)
      end    
    end
  end
  
  return selection.end_line
end

local function getNewSelectionStartLineWhenMovingDown()

  local selection = renoise.song().selection_in_pattern

  for i = 1, #columnMatrix do    
    for j = 1, #columnMatrix[i] do
    
      if not columnMatrix[i][j].is_empty then
      
        for rowIndex = 1, i-1 do
          table.remove(cellMatrix, 1)
          table.remove(columnMatrix, 1)
        end
      
        return selection.start_line + i - 1
      end
    end
  end
  
  return selection.start_line
end

local function getLastIndexOfColumnMatrix()

  if selectionEndsOnTheLastLine() then
    return #columnMatrix
  else
    return #columnMatrix-1
  end
end

local function getNewSelectionEndLineWhenMovingDown()

  local selection = renoise.song().selection_in_pattern
  local lastIndex = getLastIndexWhenMovingDown()
  local numberOfLinesInColumnMatrix = #columnMatrix
 
  local lastIndexOfColumnMatrix = getLastIndexOfColumnMatrix()
 
  for i = lastIndexOfColumnMatrix, 1, -1  do    
    for j = #columnMatrix[i], 1, -1 do
    
      if not columnMatrix[i][j].is_empty then
      
        for rowIndex = #columnMatrix, i+2, -1  do        
          table.remove(columnMatrix)
          table.remove(cellMatrix)
        end
      
        return lastIndex - (numberOfLinesInColumnMatrix - i)
      end    
    end
  end
  
  return selection.end_line
end


function shrinkSelectionRangeWhenMovingUp()

  local selection = renoise.song().selection_in_pattern
  
  local newSelectionStartLine = getNewSelectionStartLineWhenMovingUp()
  local newSelectionEndLine = getNewSelectionEndLineWhenMovingUp()
  
  selection.start_line = newSelectionStartLine
  selection.end_line = newSelectionEndLine
  
  renoise.song().selection_in_pattern = selection
end

function shrinkSelectionRangeWhenMovingDown()

  local selection = renoise.song().selection_in_pattern

  local newSelectionStartLine = getNewSelectionStartLineWhenMovingDown()
  local newSelectionEndLine = getNewSelectionEndLineWhenMovingDown()
   
  selection.start_line = newSelectionStartLine
  selection.end_line = newSelectionEndLine
  
  renoise.song().selection_in_pattern = selection
end
