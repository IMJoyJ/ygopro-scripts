--融合失敗
-- 效果：
-- 融合怪兽特殊召唤时发动。场上存在的融合怪兽全部回到融合卡组。
function c58392024.initial_effect(c)
	-- 融合怪兽特殊召唤时发动。场上存在的融合怪兽全部回到融合卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c58392024.condition)
	e1:SetTarget(c58392024.target)
	e1:SetOperation(c58392024.activate)
	c:RegisterEffect(e1)
end
-- 检查特殊召唤成功的怪兽中是否存在融合怪兽，作为发动的条件
function c58392024.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_FUSION)
end
-- 过滤场上的融合怪兽且能回到额外卡组的卡
function c58392024.filter(c)
	return c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end
-- 效果发动的目标选择与处理，检查场上是否存在符合条件的融合怪兽，并设置操作信息为将这些卡送回卡组
function c58392024.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查场上是否存在至少1只可以回到额外卡组的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58392024.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有可以回到额外卡组的融合怪兽
	local g=Duel.GetMatchingGroup(c58392024.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁的操作信息，表示将场上所有的融合怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理，获取场上所有的融合怪兽并将其送回额外卡组
function c58392024.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有可以回到额外卡组的融合怪兽
	local g=Duel.GetMatchingGroup(c58392024.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将获取到的融合怪兽全部送回持有者的额外卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
end
