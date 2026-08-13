--ドル・ドラ
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次。
-- ①：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡的攻击力·守备力变成1000。
function c43586926.initial_effect(c)
	-- 这个卡名的效果在决斗中只能使用1次。①：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c43586926.regop)
	c:RegisterEffect(e1)
end
-- 当这张卡被破坏并从场上送去墓地时，在墓地中给自身注册一个结束阶段可发动的特殊召唤诱发效果，并设置该效果在决斗中只能使用1次。
function c43586926.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- 这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡的攻击力·守备力变成1000。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(43586926,0))  --"特殊召唤"
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,43586926+EFFECT_COUNT_CODE_DUEL)
		e1:SetTarget(c43586926.sptg)
		e1:SetOperation(c43586926.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 作为该效果的发动条件，检查墓地中的这张卡是否能被当前玩家特殊召唤；若可以则继续登记特殊召唤的操作信息。
function c43586926.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次效果将进行的特殊召唤操作：将这张卡作为对象、数量为1，使系统能识别并供其他效果响应此特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡仍与效果关联，则将其以表侧表示特殊召唤到发动者场上；成功后就给它附加攻击力·守备力变成1000的效果，最后完成特殊召唤处理。
function c43586926.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍与效果存在联系，并尝试将其以表侧表示特殊召唤；若成功则进入后续攻击力·守备力变更处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡的攻击力·守备力变成1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		c:RegisterEffect(e2)
	end
	-- 完成通过SpecialSummonStep逐步进行的特殊召唤，使本次特殊召唤正式成立并触发相关的特殊召唤成功时点。
	Duel.SpecialSummonComplete()
end
