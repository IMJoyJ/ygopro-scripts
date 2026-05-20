--成功確率0％
-- 效果：
-- 从对方额外卡组随机选择2张融合怪兽送去墓地。
function c6859683.initial_effect(c)
	-- 从对方额外卡组随机选择2张融合怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c6859683.target)
	e1:SetOperation(c6859683.operation)
	c:RegisterEffect(e1)
end
-- 过滤对方额外卡组中是里侧表示或融合怪兽且能送去墓地的卡
function c6859683.filter(c)
	return (c:IsFacedown() or c:IsType(TYPE_FUSION)) and c:IsAbleToGrave()
end
-- 效果发动的目标与条件检查：确认对方额外卡组中符合条件的卡是否在2张以上
function c6859683.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方额外卡组的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if chk==0 then return g:FilterCount(c6859683.filter,nil)>=2 end
end
-- 效果处理：从对方额外卡组随机选择2张融合怪兽送去墓地
function c6859683.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组中所有的融合怪兽
	local g=Duel.GetMatchingGroup(Card.IsType,1-tp,LOCATION_EXTRA,0,nil,TYPE_FUSION)
	if g:GetCount()<2 then return end
	local rg=g:RandomSelect(tp,2)
	-- 将随机选出的2张卡因效果送去墓地
	Duel.SendtoGrave(rg,REASON_EFFECT)
end
