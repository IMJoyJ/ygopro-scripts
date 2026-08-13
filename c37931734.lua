--王の襲来
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的卡组·墓地选1张「王战」场地魔法卡发动。那之后，对方从卡组抽1张。
function c37931734.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的卡组·墓地选1张「王战」场地魔法卡发动。那之后，对方从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37931734+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c37931734.target)
	e1:SetOperation(c37931734.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：选择卡名含有「王战」字段、类型为场地魔法、且其发动效果在当前状态下可由tp发动（不检查位置和对象）的卡。
function c37931734.filter(c,tp)
	return c:IsSetCard(0x134) and c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 效果发动前的合法性判定：当chk==0时返回是否存在可选的目标卡以及对方能否抽卡，用于决定效果是否可以发动。
function c37931734.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若处于发动检查阶段，判断自己卡组·墓地是否存在至少1张符合c37931734.filter的「王战」场地魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c37931734.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
		-- 同时判断对方玩家能否抽1张卡，若不能则不能发动；此为发动条件之一。
		and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 登记本次效果将执行抽卡操作的预测信息：抽卡分类为CATEGORY_DRAW，抽卡玩家为对方（1-tp），数量为1，为后续连锁判定提供信息。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- 效果处理：从自己卡组·墓地选取1张符合条件的「王战」场地魔法卡（受王谷影响的除外），若自己场地区已有卡则将其以规则理由送入墓地，然后把选中的卡表侧放置到场地区并发动其效果，最后让对方抽1张卡。
function c37931734.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择框提示，让tp选择要放置到场上的卡片，提示文本为“请选择要放置到场上的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让tp从自己卡组·墓地中选择1张通过aux.NecroValleyFilter过滤的符合c37931734.filter的「王战」场地魔法卡，并取回选中卡对象；若选中则继续处理。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c37931734.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取自己场地区域第0个位置的卡，即当前自己场上的场地魔法卡（若有）。
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 将原场地魔法卡以规则理由（REASON_RULE）送入墓地，即场地魔法卡替换的规则处理。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使后续放置新场地和抽卡处理不在同一时点，防止错误连锁时点。
			Duel.BreakEffect()
		end
		-- 将选中的「王战」场地魔法卡以表侧表示放置到自己的场地区域，同时立刻适用其效果（enable=true）。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发该场地魔法卡的发动事件（event 4179255），使其发动效果进入连锁处理，相当于手动发动该场地卡的卡片发动效果。
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		-- 再次中断效果处理，使对方抽卡与前段处理分开，确保时点正确。
		Duel.BreakEffect()
		-- 让对方（1-tp）因效果（REASON_EFFECT）抽1张卡。
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
end
