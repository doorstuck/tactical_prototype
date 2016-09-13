require "skills/active_skill_base"
require "map/map_point"

Skills.Active.MeleeStrike = {}
Skills.Active.MeleeStrike.__index =  Skills.Active.MeleeStrike

Skills.Active.MeleeStrike.ap_cost = 3
Skills.Active.MeleeStrike.damage = 18
Skills.Active.MeleeStrike.img_src = '/assets/skills/sword.png'

function Skills.Active.MeleeStrike.new()
  skill = {}
  setmetatable(skill, Skills.Active.MeleeStrike)
  Skills.Active.ActiveSkillBase.new(skill)
  return skill
end

setmetatable(Skills.Active.MeleeStrike,{__index = Skills.Active.ActiveSkillBase})

function Skills.Active.MeleeStrike.CellsEffected(char, map, target_cell_x, target_cell_y)
  result = {}
  point = MapPoint.new(target_cell_x, target_cell_y)
  table.insert(result, point)
  return result
end

function Skills.Active.MeleeStrike.CanTarget(char, map, target_cell_x, target_cell_y)
  if not Skills.Active.ActiveSkillBase.IsEnemy(char, map, target_cell_x, target_cell_y) then return false end
  if math.abs(target_cell_x - char.cell_x) <= 1 and math.abs(target_cell_y - char.cell_y) <= 1 then
    return true
  end
  
  return false
end

function Skills.Active.MeleeStrike:Execute(char, map, target_cell_x, target_cell_y)
  target_char = map:GetChar(target_cell_x, target_cell_y)
  if not target_char then
    LogError("Tried to hit a char that does not exist on map! X: " .. target_cell_x .. " Y: " .. target_cell_y)
    return
  end

  target_char.hp = target_char.hp - self.damage

  LogDebug("Hitting character for " .. self.damage .. ". Character now has " .. target_char.hp)
end
