--無差別崩壊
-- 效果：
-- ①：掷2次骰子。等级·阶级比出现的数目合计低的场上的表侧表示怪兽全部破坏。
function c22802010.initial_effect(c)
	-- ①：掷2次骰子。等级·阶级比出现的数目合计低的场上的表侧表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c22802010.target)
	e1:SetOperation(c22802010.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：判断怪兽是否为表侧表示，且等级或阶级不大于lv（即等级/阶级小于等于lv），用于筛选在骰子合计下会被破坏的怪兽。
function c22802010.filter(c,lv)
	return c:IsFaceup() and (c:IsLevelBelow(lv) or c:IsRankBelow(lv))
end
-- 发动时的处理函数：在chk==0时检查是否存在可能被破坏的怪兽，若可发动则获取最小被破坏对象组，并设置骰子与破坏的操作信息。
function c22802010.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点判定：检查场上是否存在至少1只表侧表示且等级/阶级不超过11的怪兽，作为能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c22802010.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,11) end
	-- 获取场上所有表侧表示且等级/阶级在1以下的怪兽组，作为骰子合计最小时也必定会被破坏的候选对象，供操作信息使用。
	local g=Duel.GetMatchingGroup(c22802010.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,1)
	-- 设置骰子操作信息：由当前玩家tp投掷2次骰子（用于稍后判定破坏范围）。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
	-- 设置破坏操作信息：将候选怪兽组g及其数量登记为本次连锁可能破坏的对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数：执行时投掷2次骰子，根据骰子合计值筛选出等级/阶级低于合计值的表侧表示怪兽，并将其全部破坏。
function c22802010.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让当前玩家tp投掷2次骰子，d1、d2分别记录两次的点数。
	local d1,d2=Duel.TossDice(tp,2)
	-- 以骰子合计值减1作为等级/阶级上限，获取场上等级/阶级不高于此数值（即严格低于骰子合计）的表侧表示怪兽组。
	local g=Duel.GetMatchingGroup(c22802010.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,d1+d2-1)
	if g:GetCount()>0 then
		-- 将筛选出的怪兽组g以效果（REASON_EFFECT）为原因破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
