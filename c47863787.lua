--アーティファクト－ラブリュス
-- 效果：
-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。魔法与陷阱卡区域盖放的这张卡在对方回合被破坏送去墓地时，这张卡特殊召唤。此外，名字带有「古遗物」的卡被破坏送去自己墓地时才能发动。这张卡从手卡特殊召唤。
function c47863787.initial_effect(c)
	-- 效果原文：这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- 效果原文：魔法与陷阱卡区域盖放的这张卡在对方回合被破坏送去墓地时，这张卡特殊召唤。此外，名字带有「古遗物」的卡被破坏送去自己墓地时才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47863787,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c47863787.spcon)
	e2:SetTarget(c47863787.sptg)
	e2:SetOperation(c47863787.spop)
	c:RegisterEffect(e2)
	-- 效果原文：此外，名字带有「古遗物」的卡被破坏送去自己墓地时才能发动。这张卡从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(47863787,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c47863787.spcon2)
	e3:SetTarget(c47863787.sptg2)
	e3:SetOperation(c47863787.spop)
	c:RegisterEffect(e3)
end
-- 规则层面：判断此卡是否在对方回合被破坏送入墓地，且之前处于魔陷区背面表示，且为我方控制。
function c47863787.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 规则层面：判断此卡是否因破坏而进入墓地，且当前回合不是我方回合。
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- 规则层面：设置效果处理时的特殊召唤操作信息。
function c47863787.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：设置特殊召唤的操作信息，指定目标为自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面：执行特殊召唤操作，将此卡以正面表示形式特殊召唤到场上。
function c47863787.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 规则层面：将此卡以正面表示形式特殊召唤到我方场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 规则层面：定义过滤器函数，用于判断是否为我方控制的、带有「古遗物」字段且因破坏送入墓地的卡。
function c47863787.cfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x97) and c:IsReason(REASON_DESTROY)
end
-- 规则层面：判断是否有满足条件的「古遗物」卡被破坏送入墓地。
function c47863787.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47863787.cfilter,1,nil,tp)
end
-- 规则层面：检查手牌是否可以特殊召唤，包括场地空位和召唤条件。
function c47863787.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查我方场上是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面：设置特殊召唤的操作信息，指定目标为自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
