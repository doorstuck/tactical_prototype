require "skills/active_skill_base"
require "map/map_point"

Skills.Active.Fireball = {}
Skills.Active.Fireball.__index =  Skills.Active.Fireball

Skills.Active.Fireball.ap_cost = 3
Skills.Active.Fireball.damage = 18
Skills.Active.Fireball.img_src = '/assets/skills/scroll.png'
Skills.Active.Fireball.working_distance = 4

function Skills.Active.Fireball.new()
  skill = {}
  setmetatable(skill, Skills.Active.Fireball)
  Skills.Active.ActiveSkillBase.new(skill)
  return skill
end

setmetatable(Skills.Active.Fireball,{__index = Skills.Active.ActiveSkillBase})

function Skills.Active.Fireball.CellsEffected(char, map, target_cell_x, target_cell_y)
  result = {}
  local cell_x = target_cell_x - 1
  local cell_y = target_cell_y - 1
  for cell_x = target_cell_x - 1, target_cell_x + 1, 1 do
    for cell_y = target_cell_y - 1, target_cell_y + 1, 1 do
      point = MapPoint.new(cell_x, cell_y)
      table.insert(result, point)
    end
  end

  return result
end

function Skills.Active.Fireball.CanTarget(char, map, target_cell_x, target_cell_y)
  if math.abs(char.cell_x - target_cell_x) < Skills.Active.Fireball.working_distance and math.abs(char.cell_y - target_cell_y) < Skills.Active.Fireball.working_distance then
    return true
  end
  
  return false
end

function Skills.Active.Fireball:Execute(char, map, target_cell_x, target_cell_y)
  for i, cell_affected in pairs(self.CellsEffected(char, map, target_cell_x, target_cell_y)) do
    target_char = map:GetChar(cell_affected.cell_x, cell_affected.cell_y)
    if target_char then
      target_char.hp = target_char.hp - self.damage
    end
  end
end
