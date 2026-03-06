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
-- 过滤函数，检查场上是否存在表侧表示且等级或阶级低于指定值的怪兽
function c22802010.filter(c,lv)
	return c:IsFaceup() and (c:IsLevelBelow(lv) or c:IsRankBelow(lv))
end
-- 效果发动时点的处理函数，用于确认是否满足发动条件并设置连锁信息
function c22802010.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张满足过滤条件的怪兽（等级或阶级低于11）
	if chk==0 then return Duel.IsExistingMatchingCard(c22802010.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,11) end
	-- 获取场上所有满足过滤条件的怪兽组（等级或阶级低于1）
	local g=Duel.GetMatchingGroup(c22802010.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,1)
	-- 设置连锁操作信息为投掷2次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
	-- 设置连锁操作信息为破坏满足条件的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果发动时的处理函数，执行骰子投掷和破坏效果
function c22802010.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家投掷2次骰子，返回两次骰子结果
	local d1,d2=Duel.TossDice(tp,2)
	-- 获取场上所有满足过滤条件的怪兽组（等级或阶级低于骰子结果之和减1）
	local g=Duel.GetMatchingGroup(c22802010.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,d1+d2-1)
	if g:GetCount()>0 then
		-- 将满足条件的怪兽组全部破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
