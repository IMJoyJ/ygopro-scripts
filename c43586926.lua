--ドル・ドラ
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次。
-- ①：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡的攻击力·守备力变成1000。
function c43586926.initial_effect(c)
	-- 效果原文内容：这个卡名的效果在决斗中只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c43586926.regop)
	c:RegisterEffect(e1)
end
-- 规则层面操作：当此卡因破坏被送入墓地时，注册一个在结束阶段发动的特殊召唤效果。
function c43586926.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- 效果原文内容：①：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。这张卡从墓地特殊召唤。
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
-- 规则层面操作：判断此卡是否可以被特殊召唤。
function c43586926.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面操作：设置此卡特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面操作：处理特殊召唤的后续操作，包括设置攻击力和守备力。
function c43586926.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面操作：检查此卡是否与效果相关且特殊召唤步骤成功。
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 效果原文内容：这个效果特殊召唤的这张卡的攻击力·守备力变成1000。
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
	-- 规则层面操作：完成特殊召唤流程。
	Duel.SpecialSummonComplete()
end
