--海造賊－金髪の訓練生
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从这张卡以外的手卡以及自己场上的表侧表示的卡之中把1张「海造贼」怪兽卡送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡在墓地存在的场合，丢弃1张手卡才能发动。这张卡特殊召唤。这个回合，自己不是「海造贼」怪兽不能特殊召唤。
function c81344070.initial_effect(c)
	-- ①：从这张卡以外的手卡以及自己场上的表侧表示的卡之中把1张「海造贼」怪兽卡送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81344070,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,81344070)
	e1:SetCost(c81344070.spcost)
	e1:SetTarget(c81344070.sptg)
	e1:SetOperation(c81344070.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，丢弃1张手卡才能发动。这张卡特殊召唤。这个回合，自己不是「海造贼」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81344070,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,81344071)
	e2:SetCost(c81344070.cost)
	e2:SetTarget(c81344070.target)
	e2:SetOperation(c81344070.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：可送去墓地的「海造贼」怪兽卡，且该卡送去墓地后能腾出可用的怪兽区域
function c81344070.cfilter(c,tp)
	return c:IsAbleToGraveAsCost() and c:IsSetCard(0x13f) and c:GetOriginalType()&TYPE_MONSTER~=0
		-- 检查卡片是否在场上表侧表示或在手卡，且该卡送去墓地后自己场上有可用的怪兽区域
		and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的发动代价：从这张卡以外的手卡·场上表侧表示的卡中将1张「海造贼」怪兽卡送去墓地
function c81344070.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或场上是否存在除自身以外、满足送墓条件的「海造贼」怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(c81344070.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张满足条件的「海造贼」怪兽卡
	local g=Duel.SelectMatchingCard(tp,c81344070.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,e:GetHandler(),tp)
	-- 将选择的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c81344070.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将手卡的这张卡特殊召唤
function c81344070.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的发动代价：丢弃1张手卡
function c81344070.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 效果②的发动准备：检查怪兽区域空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c81344070.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将墓地的这张卡特殊召唤，并适用特殊召唤限制效果
function c81344070.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是「海造贼」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c81344070.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，限制玩家本回合的特殊召唤
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的怪兽不能是「海造贼」以外的怪兽
function c81344070.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x13f)
end
