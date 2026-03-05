--オーバーウェルム
-- 效果：
-- 自己场上有7星以上的上级召唤的怪兽表侧表示存在的场合才能发动。陷阱卡或者效果怪兽的效果的发动无效并破坏。
function c20140382.initial_effect(c)
	-- 效果原文内容：自己场上有7星以上的上级召唤的怪兽表侧表示存在的场合才能发动。陷阱卡或者效果怪兽的效果的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c20140382.condition)
	e1:SetTarget(c20140382.target)
	e1:SetOperation(c20140382.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足条件的怪兽（表侧表示、等级7以上、上级召唤）
function c20140382.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果作用：满足发动条件（己方场上有符合条件的怪兽、连锁可无效、发动的是怪兽效果或陷阱卡发动）
function c20140382.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查己方场上是否存在满足条件的怪兽
	return Duel.IsExistingMatchingCard(c20140382.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 效果作用：检查连锁是否可以被无效
		and Duel.IsChainNegatable(ev)
		and (re:IsActiveType(TYPE_MONSTER) or (re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)))
end
-- 效果作用：设置连锁处理信息（使发动无效、可能破坏目标卡）
function c20140382.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置连锁处理信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：设置连锁处理信息为破坏目标卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果作用：执行效果处理（使连锁无效并破坏目标卡）
function c20140382.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：使连锁无效并检查目标卡是否与效果相关
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：以效果原因破坏目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
