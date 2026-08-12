--重量オーバー
-- 效果：
-- 对方对怪兽的特殊召唤成功时才能发动。场上的2星以下的怪兽全部从游戏中除外。
function c63193536.initial_effect(c)
	-- 对方对怪兽的特殊召唤成功时才能发动。场上的2星以下的怪兽全部从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c63193536.condition)
	e1:SetTarget(c63193536.target)
	e1:SetOperation(c63193536.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查怪兽是否由指定玩家特殊召唤
function c63193536.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 发动条件：检查特殊召唤的怪兽中是否存在至少1只由对方玩家特殊召唤的怪兽
function c63193536.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c63193536.cfilter,1,nil,1-tp)
end
-- 过滤条件：场上表侧表示、等级2以下且可以被除外的怪兽
function c63193536.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(2) and c:IsAbleToRemove()
end
-- 发动准备：检查场上是否存在满足条件的怪兽，并设置除外操作的信息
function c63193536.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查双方场上是否存在至少1只表侧表示且等级2以下的可以被除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c63193536.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上所有满足过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c63193536.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁的操作信息，表示该效果的处理为将这些怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理：获取场上所有满足条件的怪兽，并将其全部表侧表示除外
function c63193536.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新获取双方场上所有满足过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c63193536.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将符合条件的怪兽全部以表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
