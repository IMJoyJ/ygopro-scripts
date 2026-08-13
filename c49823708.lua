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
	-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。②：把这张卡解放才能发动。从自己的手卡·墓地选1只「破坏之剑士」特殊召唤。
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
	-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。③：这张卡在墓地存在，自己场上有「破坏之剑士」存在的场合，从手卡丢弃1张「破坏剑」卡才能发动。这张卡特殊召唤。
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
-- ①效果的检索过滤条件：筛选卡名属于「破坏剑」字段、不是「破坏剑士的伴龙」，且能被加入手卡的卡片。
function c49823708.filter(c)
	return c:IsSetCard(0xd6) and not c:IsCode(49823708) and c:IsAbleToHand()
end
-- ①效果的发动条件与操作信息登记：确认卡组存在可检索的「破坏剑」卡，并将本次连锁登记为从卡组加入手卡的效果。
function c49823708.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定发动是否合法：自己卡组存在至少1张满足c49823708.filter的「破坏剑」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c49823708.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 将本次处理信息登记为把卡组中1张卡加入手卡（CATEGORY_TOHAND），供后续效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理：从卡组选择1张符合条件的「破坏剑」卡加入手卡，并让对方确认。
function c49823708.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示“请选择要加入手牌的卡”，引导玩家选取检索目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组筛选并选出1张满足条件的「破坏剑」卡。
	local g=Duel.SelectMatchingCard(tp,c49823708.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，原因为效果处理（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次加入手卡的卡片，以确认检索内容。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的代价函数：确认这张卡可以被解放，并将其解放作为特殊召唤的代价。
function c49823708.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将「破坏剑士的伴龙」自身解放，作为发动②效果的代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ②效果的特殊召唤对象筛选：卡号为78193831的「破坏之剑士」，并确认其可以被当前效果特殊召唤。
function c49823708.spfilter(c,e,tp)
	return c:IsCode(78193831) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件：解放自身后可腾出怪兽区域，且我方手卡·墓地存在可特殊召唤的「破坏之剑士」。
function c49823708.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测可用怪兽区域：因这张卡会作为代价解放，即使当前没有空位也可发动（允许空位为0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检测特殊召唤素材：我方手卡·墓地存在至少1只满足spfilter的「破坏之剑士」。
		and Duel.IsExistingMatchingCard(c49823708.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 将本次处理登记为特殊召唤效果，预定来源为手卡·墓地，数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- ②效果的处理：选择1只「破坏之剑士」从手卡·墓地以表侧表示特殊召唤。
function c49823708.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认可用怪兽区域，若没有空位则本次特殊召唤不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示“请选择要特殊召唤的卡”，引导玩家选择召唤对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只满足spfilter且不受王家长眠之谷影响的「破坏之剑士」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c49823708.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「破坏之剑士」以表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的条件过滤：判断场上存在表侧表示的「破坏之剑士」（卡号78193831）。
function c49823708.cfilter(c)
	return c:IsFaceup() and c:IsCode(78193831)
end
-- ③效果的发动条件：我方怪兽区域存在至少1张表侧表示的「破坏之剑士」。
function c49823708.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查我方场上是否存在表侧表示的「破坏之剑士」。
	return Duel.IsExistingMatchingCard(c49823708.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ③效果的代价卡过滤：从手卡中筛选「破坏剑」字段且可以作为代价丢弃的卡。
function c49823708.costfilter(c)
	return c:IsSetCard(0xd6) and c:IsAbleToGraveAsCost()
end
-- ③效果的代价：从手卡丢弃1张「破坏剑」字段的卡作为发动代价。
function c49823708.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定代价是否满足：手卡存在至少1张可丢弃的「破坏剑」字段卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c49823708.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家从手卡丢弃1张满足costfilter的「破坏剑」卡，作为发动代价（REASON_COST）。
	Duel.DiscardHand(tp,c49823708.costfilter,1,1,REASON_COST)
end
-- ③效果的目标判定：确认有可用怪兽区域，且墓地中的这张卡可以被当前效果特殊召唤。
function c49823708.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定需要至少1个可用怪兽区域，用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次处理登记为特殊召唤这张卡自身，处理对象确定为墓地中的效果持有者。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果的实际处理：若这张卡仍与效果相关，则将其从墓地特殊召唤到我方场上。
function c49823708.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将「破坏剑士的伴龙」从墓地以表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
