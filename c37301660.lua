--WINDS OF VICTORY
-- 效果：
-- 装备怪兽的攻击力上升300，变成风属性。
local s,id,o=GetID()
-- 该函数是这张卡的效果初始化入口，用于注册装备魔法卡的通用装备/限制效果，并创建“攻击力上升300”与“变成风属性”这两个装备效果。
function s.initial_effect(c)
	-- 调用通用装备魔法辅助函数，使此卡可以装备给己方或对方场上表侧表示怪兽，并建立基本的装备限制逻辑。
	aux.AddEquipSpellEffect(c,true,true,Card.IsFaceup,nil)
	-- 对应效果原文“装备怪兽的攻击力上升300”，创建一个装备效果，令装备怪兽的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	-- 对应效果原文“变成风属性”，创建一个装备效果，令装备怪兽的属性变为风属性。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetValue(ATTRIBUTE_WIND)
	c:RegisterEffect(e2)
end
