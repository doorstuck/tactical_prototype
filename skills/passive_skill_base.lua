require "skills/skill_base"

Skills.Passive.PassiveSkillBase = {}

Skills.Passive.PassiveSkillBase.__index = Skills.Passive.PassiveSkillBase

Skills.Passive.PassiveSkillBase.img_src = ""
Skills.Passive.PassiveSkillBase.name = "skill base"

function Skills.Passive.PassiveSkillBase.new(skill, char)
  skill.char = char
end

function Skills.Passive.PassiveSkillBase:GetName()
  return self.name
end

function Skills.Passive:Register(map)
end
