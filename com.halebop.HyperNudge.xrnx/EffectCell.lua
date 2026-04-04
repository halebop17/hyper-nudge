EffectCell = {}
EffectCell.__index = EffectCell

function EffectCell:new(trackIndex, lineIndex, columnIndex, effectColumn, numberOfSteps)

  local self = {}
  setmetatable(self, EffectCell)

  self.trackIndex = trackIndex
  self.lineIndex = lineIndex
  self.columnIndex = columnIndex
  self.isNote = false
  
  if effectColumn.is_empty then
    self.movingToNewLine = false
    self.isNotEmpty = false
    return self
  end

  if numberOfSteps < 0 then
    self.movingToNewLine = numberOfSteps <= -256
  else
    self.movingToNewLine = numberOfSteps >= 256
  end

  self.isNotEmpty = true
  
  return self
end

function EffectCell:updateValue(arg)

end
