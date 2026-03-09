--アルティメット・インセクト LV1
-- 效果：
-- 自己场上表侧表示存在的这张卡不会受到魔法的效果影响。自己回合的准备阶段时，可以把表侧表示的这张卡送到墓地，从手卡·卡组特殊召唤1只「究极昆虫 LV3」。（召唤·特殊召唤·反转的回合不能使用此效果）
function c49441499.initial_effect(c)
	-- 效果原文：自己场上表侧表示存在的这张卡不会受到魔法的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c49441499.efilter)
	c:RegisterEffect(e1)
	-- 效果原文：自己回合的准备阶段时，可以把表侧表示的这张卡送到墓地，从手卡·卡组特殊召唤1只「究极昆虫 LV3」。（召唤·特殊召唤·反转的回合不能使用此效果）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49441499,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c49441499.spcon)
	e2:SetCost(c49441499.spcost)
	e2:SetTarget(c49441499.sptg)
	e2:SetOperation(c49441499.spop)
	c:RegisterEffect(e2)
	-- 效果原文：（召唤·特殊召唤·反转的回合不能使用此效果）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(c49441499.regop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
c49441499.lvup={34088136}
-- 规则层面：使魔法卡的效果无法影响这张卡。
function c49441499.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
-- 规则层面：在通常召唤或特殊召唤成功时，为这张卡登记一个标记，用于限制其在该回合发动效果。
function c49441499.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(49441499,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
end
-- 规则层面：判断是否为当前回合玩家，并且该卡未在本回合发动过效果。
function c49441499.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断是否为当前回合玩家并且该卡未在本回合发动过效果。
	return tp==Duel.GetTurnPlayer() and e:GetHandler():GetFlagEffect(49441499)==0
end
-- 规则层面：支付将此卡送入墓地作为代价。
function c49441499.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 规则层面：将此卡送入墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 规则层面：过滤满足条件的「究极昆虫 LV3」卡片。
function c49441499.spfilter(c,e,tp)
	return c:IsCode(34088136) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 规则层面：设置特殊召唤效果的目标和条件。
function c49441499.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查场上是否有足够的召唤位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 规则层面：检查手牌或卡组中是否存在满足条件的「究极昆虫 LV3」。
		and Duel.IsExistingMatchingCard(c49441499.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面：设置连锁操作信息，表明将要特殊召唤一张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 规则层面：执行特殊召唤操作。
function c49441499.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：检查场上是否有足够的召唤位置。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面：提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：选择满足条件的一张「究极昆虫 LV3」。
	local g=Duel.SelectMatchingCard(tp,c49441499.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 规则层面：将选中的卡以特定方式特殊召唤到场上。
		Duel.SpecialSummon(tc,SUMMON_VALUE_LV,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
