-- Pattern editor utilities (original)

function selectionStartsOnTheFirstLine()
  return renoise.song().selection_in_pattern.start_line == 1
end

function selectionEndsOnTheLastLine()
  return renoise.song().selection_in_pattern.end_line == renoise.song().selected_pattern.number_of_lines
end

function getFirstIndexWhenMovingUp()

  if selectionStartsOnTheFirstLine() then
    return renoise.song().selection_in_pattern.start_line
  else
    return renoise.song().selection_in_pattern.start_line-1
  end
end

function getLastIndexWhenMovingDown()

  if selectionEndsOnTheLastLine() then
    return renoise.song().selection_in_pattern.end_line
  else
    return renoise.song().selection_in_pattern.end_line+1
  end
end

-- Phrase editor utilities (new)

function phraseIsAvailable()
  return renoise.song().selected_phrase ~= nil
end

function phraseLineIsFirst()
  return renoise.song().selected_phrase_line_index == 1
end

function phraseLineIsLast()
  local phrase = renoise.song().selected_phrase
  return renoise.song().selected_phrase_line_index == phrase.number_of_lines
end

function phraseSelectionStartsOnFirstLine()
  local sel = renoise.song().selection_in_phrase
  return sel ~= nil and sel.start_line == 1
end

function phraseSelectionEndsOnLastLine()
  local sel = renoise.song().selection_in_phrase
  local phrase = renoise.song().selected_phrase
  return sel ~= nil and phrase ~= nil and sel.end_line == phrase.number_of_lines
end
