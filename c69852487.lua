--希望皇アストラル・ホープ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上有超量怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：从自己的手卡·场上把这张卡以外的1张卡送去墓地才能发动。从卡组把以下的卡之内任意1张加入手卡。
-- ●「超量」魔法·陷阱卡
-- ●「拟声」魔法·陷阱卡
-- ●「异热同心」魔法·陷阱卡
-- ●「编号系」魔法·陷阱卡
function c69852487.initial_effect(c)
	-- ①：场上有超量怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69852487,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,69852487)
	e1:SetCondition(c69852487.spcon)
	e1:SetTarget(c69852487.sptg)
	e1:SetOperation(c69852487.spop)
	c:RegisterEffect(e1)
	-- ②：从自己的手卡·场上把这张卡以外的1张卡送去墓地才能发动。从卡组把以下的卡之内任意1张加入手卡。●「超量」魔法·陷阱卡●「拟声」魔法·陷阱卡●「异热同心」魔法·陷阱卡●「编号系」魔法·陷阱卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69852487,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,69852488)
	e2:SetCost(c69852487.thcost)
	e2:SetTarget(c69852487.thtg)
	e2:SetOperation(c69852487.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的超量怪兽
function c69852487.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- ①号效果发动条件：场上有超量怪兽存在
function c69852487.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1只表侧表示的超量怪兽
	return Duel.IsExistingMatchingCard(c69852487.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ①号效果发动准备：检查自身特殊召唤的合法性并设置操作信息
function c69852487.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果处理：将自身特殊召唤
function c69852487.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②号效果发动代价：将自身以外的1张手牌或场上的卡送去墓地
function c69852487.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌或场上是否存在除这张卡以外可以送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张除这张卡以外的手牌或场上的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 将选中的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：卡组中属于「超量」、「拟声」、「异热同心」或「编号系」的魔法·陷阱卡
function c69852487.thfilter(c)
	return c:IsSetCard(0x73,0x13a,0x7e,0x16a) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②号效果发动准备：检查卡组中是否存在符合条件的卡并设置操作信息
function c69852487.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c69852487.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从卡组将1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果处理：从卡组将符合条件的卡加入手牌
function c69852487.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c69852487.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
