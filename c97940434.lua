--カオスハンター
-- 效果：
-- ①：对方对怪兽的特殊召唤成功时，把这张卡以外的1张手卡丢弃才能发动。这张卡从手卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方不能把卡除外。
function c97940434.initial_effect(c)
	-- ①：对方对怪兽的特殊召唤成功时，把这张卡以外的1张手卡丢弃才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97940434,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c97940434.spcon)
	e1:SetCost(c97940434.spcost)
	e1:SetTarget(c97940434.sptg)
	e1:SetOperation(c97940434.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方不能把卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查怪兽是否由指定玩家特殊召唤
function c97940434.spfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- 发动条件：检查特殊召唤成功的怪兽中是否存在由对方特殊召唤的怪兽
function c97940434.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c97940434.spfilter,1,nil,1-tp)
end
-- 发动代价：丢弃1张手卡
function c97940434.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查手卡中是否存在除这张卡以外的可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡中丢弃1张除这张卡以外的卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 发动目标：检查我方场上是否有空位且这张卡是否能特殊召唤，并设置特殊召唤的操作信息
function c97940434.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查我方场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理的操作信息，表示将特殊召唤1张卡（自身）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡从手卡特殊召唤
function c97940434.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到我方场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
