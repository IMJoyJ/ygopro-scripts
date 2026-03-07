--炎塵爆発
-- 效果：
-- 把自己墓地存在的名字带有「熔岩」的怪兽全部从游戏中除外发动。把最多有除外的怪兽数量的场上存在的卡破坏。
function c38049934.initial_effect(c)
	-- 效果原文内容：把自己墓地存在的名字带有「熔岩」的怪兽全部从游戏中除外发动。把最多有除外的怪兽数量的场上存在的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c38049934.cost)
	e1:SetTarget(c38049934.target)
	e1:SetOperation(c38049934.activate)
	c:RegisterEffect(e1)
end
c38049934.check=false
-- 效果作用：过滤出墓地里名字带有「熔岩」且可以作为费用除外的怪兽
function c38049934.cfilter(c)
	return c:IsSetCard(0x39) and c:IsAbleToRemoveAsCost()
end
-- 效果作用：支付费用，将满足条件的怪兽从墓地除外
function c38049934.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	c38049934.check=true
	-- 效果作用：检查是否满足支付费用的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c38049934.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 效果作用：检索满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c38049934.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 效果作用：将怪兽组从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- 效果作用：设置发动时的目标选择逻辑
function c38049934.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not c38049934.check then return false end
		c38049934.check=false
		-- 效果作用：检查场上是否存在可破坏的卡
		return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	end
	c38049934.check=false
	-- 效果作用：检索场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 效果作用：设置连锁操作信息，确定要破坏的卡的数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果作用：执行破坏效果
function c38049934.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择场上满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetLabel(),aux.ExceptThisCard(e))
	-- 效果作用：将选中的卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
