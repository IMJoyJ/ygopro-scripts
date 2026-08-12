--WINDS OF VICTORY
-- 效果：
-- 装备怪兽的攻击力上升300，变成风属性。
local s,id,o=GetID()
-- 注册装备魔法卡的标准效果，包括发动条件和装备目标选择逻辑
function s.initial_effect(c)
	-- 添加装备魔法卡的标准发动效果，允许装备给己方或对方场上正面表示的怪兽
	aux.AddEquipSpellEffect(c,true,true,Card.IsFaceup,nil)
	-- 装备怪兽的攻击力上升300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	-- 装备怪兽变成风属性
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetValue(ATTRIBUTE_WIND)
	c:RegisterEffect(e2)
end
