require "skills/skill_base"

Skills = {}
Skills.Active = {}
Skills.Active.ActiveSkillBase = {}

Skills.Active.ActiveSkillBase.__index = Skills.Active.ActiveSkillBase

Skills.Active.ActiveSkillBase.cooldown = 0
Skills.Active.ActiveSkillBase.ap_cost = 0
Skills.Active.ActiveSkillBase.img_src = ""

function Skills.Active.ActiveSkillBase.new(skill)
  skill.turns_till_cooldown = 0
  skill.img = love.graphics.newImage(skill.img_src)
end

function Skills.Active.ActiveSkillBase.CanTarget(char, map, target_cell_x, target_cell_y)
  return false
end

function Skills.Active.ActiveSkillBase:PassTurn()
  if self.turns_till_cooldown > 0 then
    self.turns_till_cooldown = self.turns_till_cooldown - 1
  end
end

function Skills.Active.ActiveSkillBase:CanUse(char)
  return self.turns_till_cooldown <= 0
end

function Skills.Active.ActiveSkillBase.CellsEffected(map, char, target_cell_x, target_cell_y)
  -- Input arguments: map, character that uses that skill (in case she has any passive skills
  -- that can change the effect of that skill), and target cell.
  -- Returns Array of cells that are affected by this skill.
  return {}
end

function Skills.Active.ActiveSkillBase:GetApCost(char, map, target_cell_x, target_cell_y)
  return self.ap_cost
end

function Skills.Active.ActiveSkillBase:Execute(char, map, target_cell_x, target_cell_y)
  self.turn_till_cooldown = self.cooldown
end

function Skills.Active.ActiveSkillBase.IsEnemy(char, map, target_cell_x, target_cell_y)
  target_char = map:GetChar(target_cell_x, target_cell_y)
  if not target_char then return false end
  return char.is_player_controlled and not target_char.is_player_controlled
end

function Skills.Active.ActiveSkillBase:Draw(x, y)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self.img, x, y)
end
