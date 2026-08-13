--The supremacy SUN
-- 效果：
-- 这张卡不用这张卡的效果不能特殊召唤。场上表侧表示存在的这张卡被破坏送去墓地的场合，下个回合的准备阶段时，可以丢弃1张手卡，这张卡从墓地特殊召唤。
function c51402908.initial_effect(c)
	-- 这张卡不用这张卡的效果不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件值设为false，使这张卡不能用其他卡的效果特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的这张卡被破坏送去墓地的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c51402908.spr)
	c:RegisterEffect(e2)
	-- 下个回合的准备阶段时，可以丢弃1张手卡，这张卡从墓地特殊召唤。
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
-- 该卡被破坏并从场上表侧表示送去墓地时，注册一个flag标记，用于记录已满足发动条件。
function c51402908.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousPosition(POS_FACEUP) then
		c:RegisterFlagEffect(51402908,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- 判断是否满足发动时机：必须在该卡被破坏送去墓地的下一个回合的准备阶段，且持有flag标记。
function c51402908.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认该卡进入墓地的回合不是当前回合（即已到下个回合），且存在flag标记。
	return c:GetTurnID()~=Duel.GetTurnCount() and c:GetFlagEffect(51402908)>0
end
-- 发动时丢弃1张手卡作为代价。
function c51402908.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌选择并丢弃1张卡，丢弃原因标记为代价和丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 设定效果目标：确认有怪兽区空位且这张卡可以被特殊召唤。
function c51402908.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方场上有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 设置操作信息：本连锁将特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(51402908)
end
-- 效果处理时，若这张卡仍与效果关联，则将其特殊召唤。
function c51402908.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到我的场上。
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	end
end
