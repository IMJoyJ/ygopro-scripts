--ドットスケーパー
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，决斗中各能使用1次。
-- ①：这张卡被送去墓地的场合才能发动。这张卡特殊召唤。
-- ②：这张卡被除外的场合才能发动。这张卡特殊召唤。
function c18789533.initial_effect(c)
	-- 效果原文内容：①：这张卡被送去墓地的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18789533,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,18789533+EFFECT_COUNT_CODE_DUEL)
	e1:SetCost(c18789533.cost)
	e1:SetTarget(c18789533.target)
	e1:SetOperation(c18789533.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,18789534+EFFECT_COUNT_CODE_DUEL)
	c:RegisterEffect(e2)
end
-- 规则层面操作：检查玩家是否已使用过此效果，若未使用则注册标识效果以限制使用次数。
function c18789533.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断是否已使用过该效果，防止重复使用。
	if chk==0 then return Duel.GetFlagEffect(tp,18789533)==0 end
	-- 规则层面操作：为玩家注册一个在结束阶段重置的标识效果，用于限制该效果的使用次数。
	Duel.RegisterFlagEffect(tp,18789533,RESET_PHASE+PHASE_END,0,1)
end
-- 效果原文内容：①：这张卡被送去墓地的场合才能发动。这张卡特殊召唤。
function c18789533.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 规则层面操作：检查玩家场上是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面操作：设置连锁操作信息，表明将要进行特殊召唤操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果原文内容：①：这张卡被送去墓地的场合才能发动。这张卡特殊召唤。
function c18789533.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 规则层面操作：将卡片特殊召唤到指定玩家的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
