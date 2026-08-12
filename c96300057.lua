--W－ウィング・カタパルト
-- 效果：
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只「V-喷气虎」为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
-- ②：装备怪兽的攻击力·守备力上升400。
function c96300057.initial_effect(c)
	-- 为卡片注册同盟怪兽的标准效果（包括装备、代替破坏、特殊召唤等效果）
	aux.EnableUnionAttribute(c,c96300057.filter)
	-- ②：装备怪兽的攻击力·守备力上升400。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(400)
	c:RegisterEffect(e3)
	-- ②：装备怪兽的攻击力·守备力上升400。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetValue(400)
	c:RegisterEffect(e4)
end
-- 过滤作为同盟装备合法对象的「V-喷气虎」
function c96300057.filter(c)
	return c:IsCode(51638941)
end
