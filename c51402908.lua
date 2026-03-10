--The supremacy SUN
-- 效果：
-- 这张卡不用这张卡的效果不能特殊召唤。场上表侧表示存在的这张卡被破坏送去墓地的场合，下个回合的准备阶段时，可以丢弃1张手卡，这张卡从墓地特殊召唤。
function c51402908.initial_effect(c)
	-- 这张卡不用这张卡的效果不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法被特殊召唤，必须通过其他效果才能特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的这张卡被破坏送去墓地的场合，下个回合的准备阶段时，可以丢弃1张手卡，这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c51402908.spr)
	c:RegisterEffect(e2)
	-- 设置一个在准备阶段触发的效果，用于判断是否满足特殊召唤条件。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51402908,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c51402908.spcon)
	e3:SetCost(c51402908.spcost)
	e3:SetTarget(c51402908.sptg)
	e3:SetOperation(c51402908.spop)
	c:RegisterEffect(e3)
end
-- 当此卡因破坏被送入墓地时，在其原本位置正面表示的情况下，记录一个标记以供后续特殊召唤使用。
function c51402908.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousPosition(POS_FACEUP) then
		c:RegisterFlagEffect(51402908,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- 判断当前回合是否为该卡进入墓地的下一个回合，并且是否有对应的标记存在。
function c51402908.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确保不是当前回合并且有标记存在才能发动特殊召唤。
	return c:GetTurnID()~=Duel.GetTurnCount() and c:GetFlagEffect(51402908)>0
end
-- 设置丢弃手牌作为发动代价。
function c51402908.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在可丢弃的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃一张手牌的操作，作为发动效果的代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 设置特殊召唤的目标和条件。
function c51402908.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的空间进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 设置操作信息，表明将要特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(51402908)
end
-- 执行特殊召唤操作。
function c51402908.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以正面表示形式特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	end
end
