require "skills/active_skill_base"
require "map/map_point"

Skills.Active.Fireball = {}
Skills.Active.Fireball.__index =  Skills.Active.Fireball

Skills.Active.Fireball.ap_cost = 3
Skills.Active.Fireball.damage = 18
Skills.Active.Fireball.img_src = '/assets/skills/scroll.png'
Skills.Active.Fireball.distance = 4
Skills.Active.Fireball.diameter = 3

function Skills.Active.Fireball.new()
  skill = {}
  setmetatable(skill, Skills.Active.Fireball)
  Skills.Active.ActiveSkillBase.new(skill)
  return skill
end

setmetatable(Skills.Active.Fireball,{__index = Skills.Active.ActiveSkillBase})

function Skills.Active.Fireball:Execute(char, map, target_cell_x, target_cell_y)
  for i, cell_affected in pairs(self.CellsAffected(char, map, target_cell_x, target_cell_y)) do
    target_char = map:GetChar(cell_affected.cell_x, cell_affected.cell_y)
    if target_char then
      target_char.hp = target_char.hp - self.damage
    end
  end
end
