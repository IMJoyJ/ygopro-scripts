--比翼レンリン
-- 效果：
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只表侧表示怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
-- ②：装备怪兽的原本攻击力变成1000，同1次的战斗阶段中可以作2次攻击。
function c70298454.initial_effect(c)
	-- 为卡片注册标准的同盟怪兽机制，使其可以作为装备卡装备给任意怪兽，并具有代破和特召效果
	aux.EnableUnionAttribute(c,aux.TRUE)
	-- ②：装备怪兽的原本攻击力变成1000
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_SET_BASE_ATTACK)
	e4:SetValue(1000)
	c:RegisterEffect(e4)
	-- 同1次的战斗阶段中可以作2次攻击
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_EXTRA_ATTACK)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
