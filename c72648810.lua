--揺るがぬ絆
-- 效果：
-- ①：灵摆怪兽的效果或者已在灵摆区域存在的卡的效果由对方发动时才能发动。那个发动无效并除外。
function c72648810.initial_effect(c)
	-- ①：灵摆怪兽的效果或者已在灵摆区域存在的卡的效果由对方发动时才能发动。那个发动无效并除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(c72648810.condition)
	-- 设置发动效果的目标为：无效并除外触发连锁的卡片（使用辅助函数aux.nbtg）
	e1:SetTarget(aux.nbtg)
	e1:SetOperation(c72648810.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件：对方发动了灵摆怪兽的效果，或者已在灵摆区域存在的卡的效果，且该发动可以被无效
function c72648810.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前触发连锁的效果的发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	local atype=re:GetActiveType()
	return rp==1-tp and (bit.band(atype,TYPE_PENDULUM+TYPE_MONSTER)==TYPE_PENDULUM+TYPE_MONSTER
		or (atype==TYPE_PENDULUM+TYPE_SPELL and bit.band(loc,LOCATION_PZONE)~=0 and not re:IsHasType(EFFECT_TYPE_ACTIVATE)))
		-- 并且该连锁的发动可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 定义效果处理：使该发动无效并除外
function c72648810.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功无效该发动，且该卡片与该效果仍有联系
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该卡片表侧表示除外
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
