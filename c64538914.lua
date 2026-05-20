--震天のマンティコア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从卡组把1张「地割」或者「地碎」加入手卡。
-- ②：这张卡在墓地存在的场合，从自己的手卡·墓地把1张「地割」或者「地碎」除外才能发动。这张卡特殊召唤。
function c64538914.initial_effect(c)
	-- ①：自己主要阶段才能发动。从卡组把1张「地割」或者「地碎」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64538914,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,64538914)
	e1:SetTarget(c64538914.target)
	e1:SetOperation(c64538914.shop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，从自己的手卡·墓地把1张「地割」或者「地碎」除外才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64538914,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,64538915)
	e2:SetCost(c64538914.cost)
	e2:SetTarget(c64538914.sptg)
	e2:SetOperation(c64538914.spop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中卡名为「地割」或「地碎」且能加入手牌的卡片
function c64538914.filter(c)
	return c:IsCode(97169186,66788016) and c:IsAbleToHand()
end
-- ①效果的发动准备与效果分类设置
function c64538914.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「地割」或「地碎」
	if chk==0 then return Duel.IsExistingMatchingCard(c64538914.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为：将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组将1张「地割」或「地碎」加入手牌
function c64538914.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足条件的「地割」或「地碎」
	local g=Duel.SelectMatchingCard(tp,c64538914.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤手牌或墓地中卡名为「地割」或「地碎」且能作为代价除外的卡片
function c64538914.costfilter(c)
	return c:IsCode(97169186,66788016) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价处理
function c64538914.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌或墓地中是否存在可以作为代价除外的「地割」或「地碎」
	if chk==0 then return Duel.IsExistingMatchingCard(c64538914.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从手牌或墓地选择1张满足条件的「地割」或「地碎」
	local g=Duel.SelectMatchingCard(tp,c64538914.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡片表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的发动准备与效果分类设置
function c64538914.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：将自身特殊召唤
function c64538914.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
