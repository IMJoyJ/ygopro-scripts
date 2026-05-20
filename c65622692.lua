--Y－ドラゴン・ヘッド
-- 效果：
-- ①：1回合1次，可以把1个以下效果发动。
-- ●以自己场上1只「X-首领加农」为对象，把这张卡当作装备魔法卡使用来装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备状态的这张卡特殊召唤。
-- ②：装备怪兽的攻击力·守备力上升400。
function c65622692.initial_effect(c)
	-- 为自身注册同盟怪兽的标准效果，包括作为装备卡装备、代替破坏以及特殊召唤
	aux.EnableUnionAttribute(c,c65622692.filter)
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
-- 过滤出卡名为「X-首领加农」的怪兽作为合法的同盟装备对象
function c65622692.filter(c)
	return c:IsCode(62651957)
end
