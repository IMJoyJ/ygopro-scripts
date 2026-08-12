--Z－メタル・キャタピラー
-- 效果：
-- ①：1回合1次，可以把1个以下效果发动。
-- ●以自己场上1只「X-首领加农」或「Y-龙头」为对象，把这张卡当作装备魔法卡使用来装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备状态的这张卡特殊召唤。
-- ②：装备怪兽的攻击力·守备力上升600。
function c64500000.initial_effect(c)
	-- 调用同盟怪兽辅助函数，为这张卡注册同盟怪兽通用的装备、代破及特殊召唤效果
	aux.EnableUnionAttribute(c,c64500000.filter)
	-- ②：装备怪兽的攻击力·守备力上升600。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(600)
	c:RegisterEffect(e3)
	-- ②：装备怪兽的攻击力·守备力上升600。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetValue(600)
	c:RegisterEffect(e4)
end
-- 筛选卡名为「X-首领加农」或「Y-龙头」的怪兽，作为同盟装备的合法对象
function c64500000.filter(c)
	return c:IsCode(62651957,65622692)
end
