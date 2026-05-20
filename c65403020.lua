--エンド・オブ・アヌビス
-- 效果：
-- 当这张卡在场上以表侧表示存在时，所有以墓地里的卡为对象的，以及所有在墓地发动的魔法·陷阱·怪兽卡的效果无效。
function c65403020.initial_effect(c)
	-- 当这张卡在场上以表侧表示存在时，所有以墓地里的卡为对象的，以及所有在墓地发动的魔法·陷阱·怪兽卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetCondition(c65403020.condition)
	e1:SetOperation(c65403020.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查卡片当前是否处于墓地
function c65403020.gfilter(c)
	return c:IsLocation(LOCATION_GRAVE)
end
-- 判断当前处理的连锁是否满足在墓地发动或以墓地卡片为对象的无效条件
function c65403020.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁的发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if loc==LOCATION_GRAVE then return true end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前正在处理的连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c65403020.gfilter,1,nil)
end
-- 效果处理函数，使满足条件的连锁效果无效
function c65403020.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前正在处理的连锁的效果无效
	Duel.NegateEffect(ev)
end
