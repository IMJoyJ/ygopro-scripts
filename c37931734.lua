--王の襲来
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的卡组·墓地选1张「王战」场地魔法卡发动。那之后，对方从卡组抽1张。
function c37931734.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37931734+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c37931734.target)
	e1:SetOperation(c37931734.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足条件的「王战」场地魔法卡
function c37931734.filter(c,tp)
	return c:IsSetCard(0x134) and c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 效果作用：检查是否满足发动条件
function c37931734.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查自己卡组或墓地是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c37931734.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
		-- 效果作用：检查对方是否可以抽卡
		and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 效果作用：设置连锁操作信息为对方抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- 效果原文内容：①：从自己的卡组·墓地选1张「王战」场地魔法卡发动。那之后，对方从卡组抽1张。
function c37931734.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 效果作用：选择满足条件的「王战」场地魔法卡
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c37931734.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 效果作用：获取玩家场上的场地魔法卡
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 效果作用：将旧场地魔法卡送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 效果作用：中断当前效果处理
			Duel.BreakEffect()
		end
		-- 效果作用：将选中的卡特殊召唤到场上
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 效果作用：触发选中卡的发动时点
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		-- 效果作用：再次中断当前效果处理
		Duel.BreakEffect()
		-- 效果作用：对方从卡组抽1张卡
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
end
