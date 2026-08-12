--漆黒のパワーストーン
-- 效果：
-- 这张卡发动的场合，给这张卡放置3个魔力指示物来发动。
-- ①：自己回合1次，以可以放置魔力指示物的场上1张其他卡为对象才能发动。这张卡1个魔力指示物取除，给作为对象的卡放置1个魔力指示物。
-- ②：这张卡的魔力指示物全部被取除的场合这张卡破坏。
function c34029630.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 这张卡发动的场合，给这张卡放置3个魔力指示物来发动。（此处为这张卡在魔法与陷阱区域连锁发动期间允许放置魔力指示物的效果外文本）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_COUNTER_PERMIT+0x1)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c34029630.ctpermit)
	c:RegisterEffect(e1)
	-- 这张卡发动的场合，给这张卡放置3个魔力指示物来发动。①：自己回合1次，以可以放置魔力指示物的场上1张其他卡为对象才能发动。这张卡1个魔力指示物取除，给作为对象的卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(c34029630.target)
	e2:SetOperation(c34029630.operation)
	c:RegisterEffect(e2)
	-- ①：自己回合1次，以可以放置魔力指示物的场上1张其他卡为对象才能发动。这张卡1个魔力指示物取除，给作为对象的卡放置1个魔力指示物。
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
c34029630.mentioned_counter={
	[0x1]=true,
}
-- 判定这张卡是否可以放置魔力指示物：仅当这张卡位于魔法与陷阱区域且正处于连锁发动中时才允许放置
function c34029630.ctpermit(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_SZONE) and c:IsStatus(STATUS_CHAINING)
end
-- 卡发动时的对象选择处理：先给这张卡放置3个魔力指示物，若是自己的回合且可以取除1个魔力指示物、场上有可以放置魔力指示物的其他卡并且玩家选择发动，则将效果变为取对象并选择1张作为对象的卡，同时登记本回合已使用的标记
function c34029630.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c34029630.filter(chkc) end
	local c=e:GetHandler()
	-- 发动条件检查：确认可以向这张卡放置3个魔力指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x1,3,c) end
	c:AddCounter(0x1,3)
	-- 判断当前是否为自己的回合且这张卡可以因效果取除1个魔力指示物
	if Duel.GetTurnPlayer()==tp and c:IsCanRemoveCounter(tp,0x1,1,REASON_EFFECT)
		-- 确认场上存在这张卡以外的可以成为效果对象且可以放置魔力指示物的卡
		and Duel.IsExistingTarget(c34029630.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		-- 询问玩家是否现在使用「漆黑的能量石」的效果，选择是则继续处理
		and Duel.SelectYesNo(tp,aux.Stringid(34029630,0)) then  --"是否现在使用「漆黑的能量石」的效果？"
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 向玩家显示「请选择要放置指示物的卡」的提示消息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		-- 让玩家选择场上1张这张卡以外可以放置魔力指示物的卡作为效果对象
		Duel.SelectTarget(tp,c34029630.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
		c:RegisterFlagEffect(34029630,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	else
		e:SetProperty(0)
	end
end
-- 效果处理：取得效果对象的卡，若其仍与效果关联、这张卡可以取除1个魔力指示物且对象卡可以放置指示物，则取除这张卡1个魔力指示物并给对象卡放置1个魔力指示物
function c34029630.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and c:IsCanRemoveCounter(tp,0x1,1,REASON_EFFECT) and tc:IsCanAddCounter(0x1,1) then
		c:RemoveCounter(tp,0x1,1,REASON_EFFECT)
		tc:AddCounter(0x1,1)
	end
end
-- ①效果的发动条件判定函数
function c34029630.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己（只能在自己的回合发动）
	return Duel.GetTurnPlayer()==tp
end
-- 对象卡筛选条件：表侧表示且可以放置1个魔力指示物的卡
function c34029630.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- ①效果的对象选择处理：发动条件为本回合尚未使用过该效果、这张卡可以取除1个魔力指示物且场上存在可以成为对象的可以放置魔力指示物的其他卡
function c34029630.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c34029630.filter(chkc) end
	if chk==0 then return e:GetHandler():GetFlagEffect(34029630)==0 and e:GetHandler():IsCanRemoveCounter(tp,0x1,1,REASON_EFFECT)
		-- 确认场上存在这张卡以外的可以成为效果对象且可以放置魔力指示物的卡
		and Duel.IsExistingTarget(c34029630.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家显示「请选择要放置魔力指示物的卡」的提示消息
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(34029630,2))  --"请选择要放置魔力指示物的卡"
	-- 让玩家选择场上1张这张卡以外可以放置魔力指示物的卡作为效果对象
	Duel.SelectTarget(tp,c34029630.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
end
-- 自我破坏条件：这张卡的魔力指示物数量为0（全部被取除）时这张卡破坏
function c34029630.descon(e)
	return e:GetHandler():GetCounter(0x1)==0
end
