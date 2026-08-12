--守護竜ガルミデス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：通常怪兽被送去自己墓地的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡在墓地存在的场合，从手卡把1只龙族怪兽送去墓地才能发动。这张卡加入手卡。
function c43411769.initial_effect(c)
	-- ①：通常怪兽被送去自己墓地的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43411769,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,43411769)
	e1:SetCondition(c43411769.spcon)
	e1:SetTarget(c43411769.sptg)
	e1:SetOperation(c43411769.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，从手卡把1只龙族怪兽送去墓地才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43411769,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,43411770)
	e2:SetCost(c43411769.thcost)
	e2:SetTarget(c43411769.thtg)
	e2:SetOperation(c43411769.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断被送去墓地的卡是否为通常怪兽且控制者为指定玩家
function c43411769.cfilter(c,tp)
	return c:IsType(TYPE_NORMAL) and c:IsControler(tp)
end
-- 效果发动条件，判断是否有通常怪兽被送去墓地
function c43411769.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c43411769.cfilter,1,nil,tp)
end
-- 特殊召唤效果的发动时处理，判断是否满足特殊召唤条件
function c43411769.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，将卡片特殊召唤到场上
function c43411769.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行将卡片特殊召唤到场上的操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断手卡中是否存在龙族怪兽且能作为代价送去墓地
function c43411769.costfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToGraveAsCost()
end
-- 效果发动时的处理，选择并送去墓地1只龙族怪兽作为代价
function c43411769.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手卡中是否存在至少1只龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c43411769.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1只龙族怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,c43411769.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的龙族怪兽送去墓地作为效果的代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动时的处理，判断是否满足将卡片送回手牌的条件
function c43411769.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置将卡片送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将卡片送回手牌
function c43411769.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行将卡片送回手牌的操作
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
