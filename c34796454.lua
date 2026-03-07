--三連星のトリオン
-- 效果：
-- 这张卡作为上级召唤的解放送去墓地的回合的结束阶段时，这张卡可以从墓地特殊召唤。
function c34796454.initial_effect(c)
	-- 这张卡作为上级召唤的解放送去墓地时发动的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c34796454.regop)
	c:RegisterEffect(e1)
end
-- 检查该卡是否因上级召唤和作为素材而送去墓地，若是则设置结束阶段特殊召唤效果
function c34796454.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_SUMMON) and c:IsReason(REASON_MATERIAL) then
		-- 特殊召唤
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(34796454,0))  --"特殊召唤"
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c34796454.sptg)
		e1:SetOperation(c34796454.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 判断是否满足特殊召唤条件，包括场上是否有空位以及该卡能否被特殊召唤
function c34796454.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要进行特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将该卡从墓地特殊召唤到场上
function c34796454.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 将该卡以正面表示形式特殊召唤到玩家场上
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
end
