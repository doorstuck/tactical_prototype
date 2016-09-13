require "map/map_point"

UI = {}
UI.__index = UI

background_img = nil
background_quad = nil

selected_char = nil
selected_skill = nil

is_controlable = true
is_move_mode = false

function UI.Init()
  love.graphics.setBlendMode("alpha")
  background_img = love.graphics.newImage('assets/background/grass.jpg')
  background_quad = love.graphics.newQuad(0, 0, background_width, background_height, background_img:getDimensions())
end

function UI.Draw(map)
  UI.DrawBackground()
  UI.DrawGrid()
  UI.DrawCharacters(map)
  UI.ColorSelectedCharCell()
  UI.DrawCharacterMoves(selected_char, map)
  UI.DrawMouseOverSquare(map)
  UI.DrawSkills(map)
  UI.ColorSelectedSkill()
  UI.DrawCharsHP(map)
end

function UI.SelectChar(char)
  selected_char = char
  selected_skill = nil
end

function UI.UnselectChar()
  selected_char = nil
  selected_skill = nil
end

function UI.SelectSkill(skill)
  selected_skill = skill
end

function UI.UnselectSkill()
  selected_skill = nil
end

function UI.EnableControl()
  is_controlable = false
  love.mouse.setVisible(true)
end

function UI.DisableControl()
  is_controlable = true
  love.mouse.setVisible(false)
end

function UI.MousePressed(x, y, map)
  if not selected_char then
    UI.MousePressedNormal(x, y, map)
  elseif selected_char and not selected_skill then
    UI.MousePressedSelectedChar(x, y, map)
  elseif selected_char and selected_skill then
    UI.MousePressedSelectedSkill(x, y, map)
  end
end 

-- PRIVATE --

function UI.MousePressedNormal(x, y, map)
  cell_x, cell_y = get_cell_in(x, y)
  char_on_place = map:GetChar(cell_x, cell_y)
  if not char_on_place or not char_on_place.is_player_controlled then return end

  UI.SelectChar(char_on_place)
end

function UI.MousePressedSelectedChar(x, y, map)
  cell_x, cell_y = get_cell_in(x, y)
  char_on_place = map:GetChar(cell_x, cell_y)
  
  if char_on_place == selected_char then
    UI.UnselectChar()
    return
  end
  
  if char_on_place and char_on_place.is_player_controlled then
    UI.SelectChar(char_on_place)
    return
  end

  if UI.CharCanMoveThere(selected_char, map, cell_x, cell_y) then
    map:MoveChar(selected_char, cell_x, cell_y)
    UI.UnselectChar()
    UI.DisableControl()
    return
  end

  pressed_skill = UI.GetSkillForChar(x, y, selected_char)
  
  if pressed_skill and selected_char:CanUseSkill(pressed_skill) then
    UI.SelectSkill(pressed_skill)
  end
end

function UI.MousePressedSelectedSkill(x, y, map)
  cell_x, cell_y = get_cell_in(x, y)

  if selected_skill.CanTarget(selected_char, map, cell_x, cell_y) then
    map:ExecuteCharSkill(selected_char, selected_skill, cell_x, cell_y)
    UI.UnselectSkill()
    return
  end

  pressed_skill = UI.GetSkillForChar(x, y, selected_char)
  if not pressed_skill then
    return
  end

  if not (pressed_skill == selected_skill) and selected_char:CanUseSkill(pressed_skill) then
    UI.SelectSkill(pressed_skill)
    return
  elseif pressed_skill == selected_skill then
    UI.UnselectSkill()
  end
end

function UI.GetSkillForChar(x, y, char)
  if not char or not char.skills then return nil end
  if y < background_height + skill_icon_padding or y > background_height + skill_icon_padding + skill_icon_width then
    return nil
  end

  icon_number = math.floor(x / (skill_icon_padding + skill_icon_width)) + 1
  place_in_icon_and_padding = x % (skill_icon_padding + skill_icon_width)
  if place_in_icon_and_padding <= skill_icon_padding then
    return nil
  end

  return char.skills[icon_number]
end

function UI.DrawCharacterMoves(char, map)
  if not char then return end
  if selected_skill then return end
  local move_to_cells = map:GetCharMoveblePoints(char.cell_x, char.cell_y)
  
  for cell_hash, cell_info in pairs(move_to_cells) do
    UI.ColorCell(cell_info.point.cell_x, cell_info.point.cell_y, 0, 0, 150, 100)
  end
end

function UI.DrawGrid()
  love.graphics.setColor(0, 0, 255)
  love.graphics.setLineWidth(1)
  for i = 1, vertical_cells - 1, 1
  do
    love.graphics.line(0, i * (cell_size + 1), background_width, i * (cell_size + 1))
  end
  for i = 1, horizontal_cells - 1, 1
  do
    love.graphics.line(i * (cell_size + 1), 0, i * (cell_size + 1), background_height)
  end
end

function UI.DrawBackground()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(background_img, background_quad, 0, 0)
end

function UI.DrawMouseOverSquare(map)
  cell_x, cell_y = get_cell_in(love.mouse.getPosition())
  UI.DrawMouseOverChar(map, cell_x, cell_y)
  UI.DrawMouseOverMovableSquares(map, cell_x, cell_y)
  UI.DrawMouseOverSkillSqure(map, cell_x, cell_y)
end

function UI.DrawMouseOverChar(map, cell_x, cell_y)
  if selected_skill then return end
  local char = map:GetChar(cell_x, cell_y)
  if not char or not char.is_player_controlled then return end
  
  UI.ColorCell(cell_x, cell_y, 0, 200, 100, 100)
end

function UI.DrawMouseOverMovableSquares(map, cell_x, cell_y)
  if not selected_char then return end
  if selected_skill then return end
  
  local reachable_points = map:GetCharMoveblePoints(char.cell_x, char.cell_y)
  if not reachable_points then return end
  if not reachable_points[MapPoint.CalculateHash(cell_x, cell_y)] then return end

  UI.ColorCell(cell_x, cell_y, 0, 0, 200, 100)
end

function UI.DrawMouseOverMovableSquares(map, cell_x, cell_y)
  if not selected_char then return end
  if selected_skill then return end
  
  local reachable_points = map:GetCharMoveblePoints(char.cell_x, char.cell_y)
  if not reachable_points then return end
  if not reachable_points[MapPoint.CalculateHash(cell_x, cell_y)] then return end

  UI.ColorCell(cell_x, cell_y, 0, 0, 200, 100)
end

function UI.DrawMouseOverSkillSqure(map, cell_x, cell_y)
  if not selected_skill then return end
  
  if not selected_skill.CanTarget(selected_char, map, cell_x, cell_y) then return end
  
  for i, cell in pairs(selected_skill.CellsEffected(selected_char, map, cell_x, cell_y)) do
    UI.ColorCell(cell.cell_x, cell.cell_y, 250, 0, 0, 100)
  end
end

function UI.DrawCharacters(map)
  map:DrawChars()
end

function UI.ColorSelectedCharCell()
  if (not selected_char) then return end
  UI.ColorCell(selected_char.cell_x, selected_char.cell_y, 150, 0, 0, 100)
end

function UI.ColorSelectedSkill()
  if not selected_char or not selected_skill then return end
  UI.ColorSkill(selected_char, selected_skill, 150, 150, 0, 100)
end

function UI.ColorCell(cell_x, cell_y, r, g, b, a)
  love.graphics.setColor(r, g, b, a)
  x1, y1, x2, y2 = get_cell_coordinates(cell_x, cell_y)
  love.graphics.rectangle("fill", x1, y1, cell_size, cell_size)
end

function UI.ColorSkill(char, skill, r, g, b, a)
  love.graphics.setColor(r, g, b, a)
  x1, y1 = UI.GetSkillCoordinates(char, skill)
  love.graphics.rectangle("fill", x1, y1, skill_icon_width, skill_icon_width)
end

function UI.GetSkillCoordinates(char, skill)
  for i, this_skill in pairs(char.skills) do
    if this_skill == skill then
      x = (i - 1) * (skill_icon_padding + skill_icon_width) + skill_icon_padding
      y = background_height + skill_icon_padding
      return x, y
    end
  end
  
  LogError("Character does not have a provided skill in get skill coordinates")
  LogError("Char")
  LogError(char)
  LogError("Skill")
  LogError(skill)
  
  return nil
end

function UI.DrawSkills(map)
  if not selected_char or not selected_char.skills then return end
  left_padding = skill_icon_padding
  for i, skill in pairs(selected_char.skills) do
    local enabled = UI.DrawSkillEnabled(selected_char, skill, map)
    skill:Draw(left_padding, background_height + skill_icon_padding, not enabled)
    left_padding = left_padding + skill_icon_width + skill_icon_padding
  end
end

function UI.DrawSkillEnabled(char, skill, map)
  -- Returns wheter we should draw skill disabled when we do.
  
  if selected_skill then
    -- We are in mode where skill is selected. It means that skill
    -- should be disabled only if character cannot use it.
    return char:CanUseSkill(skill)
  elseif selected_char then
    -- We are in selected char mode. In that case if char moves
    -- to a square we need to know how many action points he will
    -- use to move there.
    cell_x, cell_y = get_cell_in(love.mouse.getPosition())
    path_length = UI.GetPathLengthTo(char, map, cell_x, cell_y)
    
    if not path_length then
      return char:CanUseSkill(skill)
    else
      return char:CanUseSkillAfterMove(skill, path_length)
    end
  end

  return true
end

function UI.GetPathLengthTo(char, map, cell_x, cell_y)
  local point_to = UI.CharCanMoveThere(char, map, cell_x, cell_y)
  if not point_to then return nil end
  return point_to.path_length
end

function UI.CharCanMoveThere(char, map, cell_x, cell_y)
  local reachable_points = map:GetCharMoveblePoints(char.cell_x, char.cell_y)
  if not reachable_points then return end
  return reachable_points[MapPoint.CalculateHash(cell_x, cell_y)]
end

function UI.DrawCharsHP(map)
  local cells_affected_by_skill = {}
  if selected_skill then
    cell_x, cell_y = get_cell_in(love.mouse.getPosition())
    cells_affected_by_skill = selected_skill.CellsEffected(selected_char, map, cell_x, cell_y)
  end
  
  for i, char in pairs(map.chars) do
    minus_hp = 0
    for j, cell in pairs(cells_affected_by_skill) do
      if cell.cell_x == char.cell_x and cell.cell_y == char.cell_y then
        minus_hp = selected_skill:GetDamage(selected_char)
      end
    end

    char:DrawHP(minus_hp)
  end
end
