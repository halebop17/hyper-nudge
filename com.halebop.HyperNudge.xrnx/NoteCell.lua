NoteCell = {}
NoteCell.__index = NoteCell

function NoteCell:new(trackIndex, lineIndex, columnIndex, noteColumn, numberOfSteps)

  local self = {}
  setmetatable(self, NoteCell)

  self.trackIndex = trackIndex
  self.lineIndex = lineIndex
  self.columnIndex = columnIndex
  self.isNote = true
  
  if noteColumn.is_empty then
    self.movingToNewLine = false
    self.isNotEmpty = false
    return self
  end
  
  self.isNotEmpty = true

  if numberOfSteps < 0 then
    self.movingToNewLine = noteColumn.delay_value+numberOfSteps < 0
  else
    self.movingToNewLine = noteColumn.delay_value+numberOfSteps > 255
  end
  
  if self.movingToNewLine then
  
    if numberOfSteps < 0 then
      self.newDelayValue = numberOfSteps + noteColumn.delay_value + 256
    else
      self.newDelayValue = numberOfSteps + noteColumn.delay_value - 256
    end
    
  else
  
    self.newDelayValue = noteColumn.delay_value + numberOfSteps
  end
  
  return self
end

function NoteCell:updateValue(noteColumn)

  noteColumn.delay_value = self.newDelayValue
end
