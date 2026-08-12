--強化支援メカ・ヘビーウェポン
-- 效果：
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只机械族怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
-- ②：装备怪兽的攻击力·守备力上升500。
function c23265594.initial_effect(c)
	-- 注册同盟怪兽效果，使该卡可以装备给机械族怪兽并具有装备代替破坏和特殊召唤效果
	aux.EnableUnionAttribute(c,c23265594.filter)
	-- 装备怪兽的攻击力上升500
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	-- 装备怪兽的守备力上升500
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetValue(500)
	c:RegisterEffect(e4)
end
-- 定义装备条件，只能装备给机械族怪兽
function c23265594.filter(c)
	return c:IsRace(RACE_MACHINE)
end
