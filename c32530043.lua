--御影志士
-- 效果：
-- 4星怪兽×2
-- 这个卡名的效果1回合只能使用1次。
-- ①：可以把这张卡1个超量素材取除，从以下效果选择1个发动。
-- ●从卡组把1只岩石族怪兽加入手卡。
-- ●从手卡把1只岩石族怪兽里侧守备表示特殊召唤。
function c32530043.initial_effect(c)
	-- 为卡片添加等级为4、需要2个超量素材的XYZ召唤手续
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ●从卡组把1只岩石族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32530043,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,32530043)
	e1:SetCost(c32530043.cost)
	e1:SetTarget(c32530043.thtg)
	e1:SetOperation(c32530043.thop)
	c:RegisterEffect(e1)
	-- ●从手卡把1只岩石族怪兽里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32530043,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,32530043)
	e2:SetCost(c32530043.cost)
	e2:SetTarget(c32530043.sptg)
	e2:SetOperation(c32530043.spop)
	c:RegisterEffect(e2)
end
-- 支付效果代价：去除1个超量素材
function c32530043.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 向对方玩家提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索满足条件的岩石族怪兽过滤器
function c32530043.thfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToHand()
end
-- 设置效果处理目标：从卡组检索1只岩石族怪兽
function c32530043.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c32530043.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理：选择并加入手牌
function c32530043.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c32530043.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 特殊召唤满足条件的岩石族怪兽过滤器
function c32530043.spfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 设置效果处理目标：从手卡特殊召唤1只岩石族怪兽
function c32530043.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否有满足条件的岩石族怪兽
		and Duel.IsExistingMatchingCard(c32530043.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息：将1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行效果处理：选择并特殊召唤
function c32530043.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c32530043.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以里侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方玩家确认特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
