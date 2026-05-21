--闇薔薇の妖精
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：调整特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡在墓地存在的场合，把自己的手卡·场上1张卡送去墓地才能发动。这张卡回到卡组最上面或者最下面。
function c90724272.initial_effect(c)
	-- ①：调整特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90724272,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,90724272)
	e1:SetCondition(c90724272.spcon)
	e1:SetTarget(c90724272.sptg)
	e1:SetOperation(c90724272.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，把自己的手卡·场上1张卡送去墓地才能发动。这张卡回到卡组最上面或者最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90724272,1))  --"回到卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,90724273)
	e2:SetCost(c90724272.tdcost)
	e2:SetTarget(c90724272.tdtg)
	e2:SetOperation(c90724272.tdop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的调整怪兽
function c90724272.spfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 检查特殊召唤的怪兽中是否存在调整怪兽
function c90724272.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c90724272.spfilter,1,nil)
end
-- 效果①的发动准备与效果处理确定（检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息）
function c90724272.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息（将自身特殊召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（将自身从手卡特殊召唤）
function c90724272.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动代价（将自己手卡或场上的一张卡送去墓地）
function c90724272.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或场上是否存在可以作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己手卡或场上1张可以作为代价送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的发动准备与效果处理确定（检查自身是否能回到卡组，并设置回到卡组的操作信息）
function c90724272.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置回到卡组的操作信息（将自身回到卡组）
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理（让玩家选择将自身回到卡组最上面或者最下面）
function c90724272.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 让玩家选择将卡片放置在卡组最上面还是最下面
		local opt=Duel.SelectOption(tp,aux.Stringid(90724272,2),aux.Stringid(90724272,3))  --"卡组最上面/卡组最下面"
		-- 将自身送回卡组的最上面或最下面
		Duel.SendtoDeck(e:GetHandler(),nil,opt,REASON_EFFECT)
	end
end
