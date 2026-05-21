--神星なる領域
-- 效果：
-- 只要这张卡在场上存在，光属性怪兽的效果的发动不会被无效化。
function c86825483.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，光属性怪兽的效果的发动不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(c86825483.efilter)
	c:RegisterEffect(e2)
end
-- 过滤当前连锁中发动的效果，判断其是否为光属性怪兽的效果
function c86825483.efilter(e,ct)
	-- 获取指定连锁序号对应的连锁效果
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	local tc=te:GetHandler()
	return te:IsActiveType(TYPE_MONSTER) and tc:IsAttribute(ATTRIBUTE_LIGHT)
end
