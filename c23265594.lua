--強化支援メカ・ヘビーウェポン
-- 效果：
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只机械族怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
-- ②：装备怪兽的攻击力·守备力上升500。
function c23265594.initial_effect(c)
	-- 调用同盟辅助函数，为这张卡注册同盟怪兽共有的规则效果：1回合1次可作为装备卡给场上机械族怪兽装备（或从装备状态特殊召唤），同时具备代替装备怪兽被战斗/效果破坏的效果，并指定装备对象必须为机械族怪兽。
	aux.EnableUnionAttribute(c,c23265594.filter)
	-- ②：装备怪兽的攻击力·守备力上升500（本段实现攻击力上升500的部分）。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	-- ②：装备怪兽的攻击力·守备力上升500（本段实现守备力上升500的部分）。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetValue(500)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断卡片是否为机械族怪兽，作为这张卡装备对象的筛选条件。
function c23265594.filter(c)
	return c:IsRace(RACE_MACHINE)
end
