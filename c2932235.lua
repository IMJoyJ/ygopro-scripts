--サウザンド・アンブラル
local s,id,o=GetID()
-- 定义initial_effect函数，用于注册卡片效果。
function s.initial_effect(c)
	-- 将卡片代码39513225添加到代码列表中。
	aux.AddCodeList(c,39513225)
	-- 创建并注册一个快速效果，该效果可以在手牌或怪兽区域发动，在怪兽正面上场或结束阶段触发，限制每回合只能使用一次，需要支付COST，指定目标，并执行操作。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.actcost)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	-- 为卡片注册一个“此卡已在墓地”的标记检测效果。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 创建并注册一个字段诱发效果，该效果在特殊召唤成功时触发，延迟生效，条件是存在XYZ怪兽，指定目标，并执行操作。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetLabelObject(e0)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义actcost函数，用于处理效果的COST。如果chk为0，则检查卡片是否可以作为COST送入墓地。
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将当前卡片以REASON_COST的原因送入墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义pfilter函数，用于过滤可选择的场地魔法卡。
function s.pfilter(c,tp)
	return not c:IsForbidden() and c:IsType(TYPE_FIELD) and c:IsCode(39513225) and c:CheckUniqueOnField(tp)
end
-- 定义acttg函数，用于指定效果的目标。如果chk为0，则检查牌组或手牌中是否存在满足s.pfilter条件的卡片。
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查牌组或手牌中是否存在满足s.pfilter条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tp) end
end
-- 定义actop函数，用于执行效果的操作。提示玩家选择要放置到场上的卡片，然后将选定的卡片移动到法师区，并注册一个字段效果以限制特殊召唤。
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从牌组或手牌中选择一张满足s.pfilter条件的卡片。
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取当前玩家的法师区第一个卡片。
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 将法师区的卡片以REASON_RULE的原因送入墓地。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果，使之后的效果处理视为不同时处理。
			Duel.BreakEffect()
		end
		-- 将选定的卡片移动到当前玩家的法师区，正面朝上显示。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
	-- 创建并注册一个字段效果，该效果禁止特殊召唤怪兽，并且在回合结束阶段重置。如果当前回合玩家是发动者，则重置时间为阶段结束+自身回合结束；否则，仅为阶段结束。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 判断当前回合的玩家是否为卡片的发动者。
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	end
	-- 将字段效果注册到玩家处。
	Duel.RegisterEffect(e1,tp)
end
-- 定义splimit函数，用于限制特殊召唤的目标。如果目标不是XYZ怪兽并且在额外怪兽区域，则返回true。
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 定义cfilter函数，用于过滤满足条件的XYZ怪兽。如果卡片是XYZ怪兽、正面朝上显示，且与先前记录的效果不同，则返回true。
function s.cfilter(c,se)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 定义spcon函数，用于判断特殊召唤效果的条件。检查是否存在满足s.cfilter条件的卡片。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,se)
end
-- 定义sptg函数，用于指定特殊召唤的目标。如果chk为0，则检查怪兽区是否有空位并且当前卡片是否可以特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示这是一个特殊召唤效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义spop函数，用于执行特殊召唤的操作。如果卡片与连锁有关，则将其特殊召唤到场上，并注册一个字段效果来改变伤害计算和禁止效果伤害。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将当前卡片特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 创建并注册字段效果，用于改变伤害计算和禁止效果伤害。该效果在阶段结束时重置。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册字段效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册字段效果。
	Duel.RegisterEffect(e2,tp)
end
-- 定义damval函数，用于计算伤害值。如果伤害原因是效果且玩家是卡片的发动者，则返回0；否则，返回原始的伤害值。
function s.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 and rp==e:GetHandlerPlayer() then return 0
	else return val end
end
