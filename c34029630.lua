--漆黒のパワーストーン
-- 效果：
-- 这张卡发动的场合，给这张卡放置3个魔力指示物来发动。
-- ①：自己回合1次，以这张卡以外的场上1张可以放置魔力指示物的卡为对象才能发动。这张卡1个魔力指示物取除，给那张卡放置1个魔力指示物。
-- ②：这张卡的魔力指示物全部被取除的场合这张卡破坏。
function c34029630.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- ①：自己回合1次，以这张卡以外的场上1张可以放置魔力指示物的卡为对象才能发动。这张卡1个魔力指示物取除，给那张卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_COUNTER_PERMIT+0x1)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c34029630.ctpermit)
	c:RegisterEffect(e1)
	-- 这张卡发动的场合，给这张卡放置3个魔力指示物来发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(c34029630.target)
	e2:SetOperation(c34029630.operation)
	c:RegisterEffect(e2)
	-- ①：自己回合1次，以这张卡以外的场上1张可以放置魔力指示物的卡为对象才能发动。这张卡1个魔力指示物取除，给那张卡放置1个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34029630,1))  --"指示物转移"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
	e3:SetCondition(c34029630.condition)
	e3:SetTarget(c34029630.target2)
	e3:SetOperation(c34029630.operation)
	c:RegisterEffect(e3)
	-- ②：这张卡的魔力指示物全部被取除的场合这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(c34029630.descon)
	c:RegisterEffect(e4)
end
-- 允许此卡在发动时放置魔力指示物。
function c34029630.ctpermit(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_SZONE) and c:IsStatus(STATUS_CHAINING)
end
-- 在发动时放置3个魔力指示物，并询问是否使用效果。
function c34029630.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c34029630.filter(chkc) end
	local c=e:GetHandler()
	-- 检查玩家是否可以向此卡放置3个魔力指示物。
	if chk==0 then return Duel.IsCanAddCounter(tp,0x1,3,c) end
	c:AddCounter(0x1,3)
	-- 检查当前回合玩家是否为发动者，并且此卡是否可以取除1个魔力指示物。
	if Duel.GetTurnPlayer()==tp and c:IsCanRemoveCounter(tp,0x1,1,REASON_EFFECT)
		-- 检查场上是否存在可以放置魔力指示物的卡。
		and Duel.IsExistingTarget(c34029630.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		-- 询问玩家是否使用此卡效果。
		and Duel.SelectYesNo(tp,aux.Stringid(34029630,0)) then  --"是否现在使用「漆黑的能量石」的效果？"
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择要放置魔力指示物的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		-- 选择目标卡并设置为效果对象。
		Duel.SelectTarget(tp,c34029630.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
		c:RegisterFlagEffect(34029630,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	else
		e:SetProperty(0)
	end
end
-- 执行效果：取除1个魔力指示物并给目标卡放置1个魔力指示物。
function c34029630.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果目标卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and c:IsCanRemoveCounter(tp,0x1,1,REASON_EFFECT) and tc:IsCanAddCounter(0x1,1) then
		c:RemoveCounter(tp,0x1,1,REASON_EFFECT)
		tc:AddCounter(0x1,1)
	end
end
-- 判断是否为当前回合玩家。
function c34029630.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家。
	return Duel.GetTurnPlayer()==tp
end
-- 判断目标卡是否为表侧表示且可以放置魔力指示物。
function c34029630.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- 设置效果目标并检查是否满足使用条件。
function c34029630.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c34029630.filter(chkc) end
	if chk==0 then return e:GetHandler():GetFlagEffect(34029630)==0 and e:GetHandler():IsCanRemoveCounter(tp,0x1,1,REASON_EFFECT)
		-- 检查场上是否存在可以放置魔力指示物的卡。
		and Duel.IsExistingTarget(c34029630.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要放置魔力指示物的卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(34029630,2))  --"请选择要放置魔力指示物的卡"
	-- 选择目标卡并设置为效果对象。
	Duel.SelectTarget(tp,c34029630.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
end
-- 当此卡魔力指示物为0时，此卡破坏。
function c34029630.descon(e)
	return e:GetHandler():GetCounter(0x1)==0
end
