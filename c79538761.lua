--トルクチューン・ギア
-- 效果：
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只表侧表示怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
-- ②：装备怪兽的攻击力·守备力上升500，当作调整使用。
function c79538761.initial_effect(c)
	-- 使用同盟怪兽辅助函数，赋予该卡同盟怪兽的标准机制（包括装备代替破坏、装备限制、装备发动以及特殊召唤效果）。
	aux.EnableUnionAttribute(c,aux.TRUE)
	-- 当作调整使用。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_ADD_TYPE)
	e4:SetValue(TYPE_TUNER)
	c:RegisterEffect(e4)
	-- ②：装备怪兽的攻击力...上升500
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetValue(500)
	c:RegisterEffect(e5)
	-- ②：装备怪兽的...守备力上升500
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_EQUIP)
	e6:SetCode(EFFECT_UPDATE_DEFENSE)
	e6:SetValue(500)
	c:RegisterEffect(e6)
end
