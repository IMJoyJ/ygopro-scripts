--破壊剣士の伴竜
-- 效果：
-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡召唤成功时才能发动。从卡组把「破坏剑士的伴龙」以外的1张「破坏剑」卡加入手卡。
-- ②：把这张卡解放才能发动。从自己的手卡·墓地选1只「破坏之剑士」特殊召唤。
-- ③：这张卡在墓地存在，自己场上有「破坏之剑士」存在的场合，从手卡丢弃1张「破坏剑」卡才能发动。这张卡特殊召唤。
function c49823708.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把「破坏剑士的伴龙」以外的1张「破坏剑」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c49823708.target)
	e1:SetOperation(c49823708.operation)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从自己的手卡·墓地选1只「破坏之剑士」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49823708,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,49823708)
	e2:SetCost(c49823708.spcost)
	e2:SetTarget(c49823708.sptg)
	e2:SetOperation(c49823708.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在，自己场上有「破坏之剑士」存在的场合，从手卡丢弃1张「破坏剑」卡才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49823708,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,49823708)
	e3:SetCondition(c49823708.spcon2)
	e3:SetCost(c49823708.spcost2)
	e3:SetTarget(c49823708.sptg2)
	e3:SetOperation(c49823708.spop2)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的「破坏剑」卡（不包括伴龙本身）并能加入手牌
function c49823708.filter(c)
	return c:IsSetCard(0xd6) and not c:IsCode(49823708) and c:IsAbleToHand()
end
-- 效果处理时检查是否满足条件：场上存在满足条件的卡
function c49823708.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：场上存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c49823708.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并把符合条件的卡加入手牌
function c49823708.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c49823708.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果处理函数，解放自身作为代价
function c49823708.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选「破坏之剑士」并能特殊召唤
function c49823708.spfilter(c,e,tp)
	return c:IsCode(78193831) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时检查是否满足条件：场上存在满足条件的卡
function c49823708.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：场上存在满足条件的卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查是否满足条件：场上存在满足条件的卡
		and Duel.IsExistingMatchingCard(c49823708.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理函数，选择并特殊召唤符合条件的怪兽
function c49823708.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足条件：场上存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c49823708.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于筛选场上的「破坏之剑士」
function c49823708.cfilter(c)
	return c:IsFaceup() and c:IsCode(78193831)
end
-- 效果处理时检查是否满足条件：场上存在满足条件的卡
function c49823708.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足条件：场上存在满足条件的卡
	return Duel.IsExistingMatchingCard(c49823708.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于筛选手牌中的「破坏剑」卡并能丢弃
function c49823708.costfilter(c)
	return c:IsSetCard(0xd6) and c:IsAbleToGraveAsCost()
end
-- 效果处理函数，丢弃1张手牌作为代价
function c49823708.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：手牌中存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c49823708.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手牌作为代价
	Duel.DiscardHand(tp,c49823708.costfilter,1,1,REASON_COST)
end
-- 效果处理时检查是否满足条件：场上存在空位且自身能特殊召唤
function c49823708.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将自身特殊召唤
function c49823708.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
