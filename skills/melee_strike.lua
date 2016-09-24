require "skills/active_skill_base"
require "map/map_point"

Skills.Active.MeleeStrike = {}
Skills.Active.MeleeStrike.__index =  Skills.Active.MeleeStrike

Skills.Active.MeleeStrike.ap_cost = 3
Skills.Active.MeleeStrike.damage = 18
Skills.Active.MeleeStrike.img_src = '/assets/skills/sword.png'
Skills.Active.MeleeStrike.name = 'melee_strike'

function Skills.Active.MeleeStrike.new()
  skill = {}
  setmetatable(skill, Skills.Active.MeleeStrike)
  Skills.Active.ActiveSkillBase.new(skill)
  return skill
end

setmetatable(Skills.Active.MeleeStrike,{__index = Skills.Active.ActiveSkillBase})

function Skills.Active.MeleeStrike:Execute(char, map, target_cell_x, target_cell_y)
  target_char = map:GetChar(target_cell_x, target_cell_y)
  if not target_char then
    LogError("Tried to hit a char that does not exist on map! X: " .. target_cell_x .. " Y: " .. target_cell_y)
    return
  end

  target_char.hp = target_char.hp - self.damage

end
