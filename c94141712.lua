--アームド・ドラゴン・サンダー LV7
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「武装龙 LV7」使用。
-- ②：从手卡把1只怪兽送去墓地才能发动。场上的这张卡送去墓地，从手卡·卡组把1只10星以下的「武装龙」怪兽特殊召唤。
-- ③：这张卡为让龙族怪兽的效果发动而被送去墓地的场合才能发动。从卡组把1张「武装龙」卡加入手卡。
function c94141712.initial_effect(c)
	-- 使这张卡在怪兽区域和墓地存在时，卡名当作「武装龙 LV7」使用。
	aux.EnableChangeCode(c,73879377,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：从手卡把1只怪兽送去墓地才能发动。场上的这张卡送去墓地，从手卡·卡组把1只10星以下的「武装龙」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94141712,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,94141712)
	e2:SetCost(c94141712.spcost)
	e2:SetTarget(c94141712.sptg)
	e2:SetOperation(c94141712.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡为让龙族怪兽的效果发动而被送去墓地的场合才能发动。从卡组把1张「武装龙」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94141712,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,94141713)
	e3:SetCondition(c94141712.thcon)
	e3:SetTarget(c94141712.thtg)
	e3:SetOperation(c94141712.thop)
	c:RegisterEffect(e3)
end
c94141712.lvup={73879377}
c94141712.lvdn={21546416,57030525}
-- 过滤手卡中可以作为发动代价送去墓地的怪兽，且此时手卡·卡组中存在可特殊召唤的「武装龙」怪兽。
function c94141712.costfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 检查手卡·卡组中是否存在至少1只（排除当前作为代价的卡后）可以特殊召唤的10星以下「武装龙」怪兽。
		and Duel.IsExistingMatchingCard(c94141712.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp)
end
-- 效果②的代价（Cost）处理函数：从手卡将1只怪兽送去墓地。
function c94141712.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足送墓代价且能让后续效果成立的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c94141712.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c94141712.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的怪兽作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤手卡·卡组中可以特殊召唤的10星以下「武装龙」怪兽。
function c94141712.spfilter(c,e,tp)
	return c:IsSetCard(0x111) and c:IsLevelBelow(10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向（Target）处理函数：检查自身是否能送墓、是否有可用怪兽格，并设置操作信息。
function c94141712.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上的这张卡是否能送去墓地，以及这张卡离场后是否能空出可用的怪兽区域。
	if chk==0 then return c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c)>0
		-- 检查手卡·卡组中是否存在可特殊召唤的10星以下「武装龙」怪兽。
		and Duel.IsExistingMatchingCard(c94141712.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置将场上的这张卡送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
	-- 设置从手卡·卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的效果处理（Operation）函数：将自身送去墓地，并从手卡·卡组特殊召唤1只10星以下「武装龙」怪兽。
function c94141712.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡在场上且因效果成功送去墓地，且此时有可用的怪兽区域。
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡·卡组选择1只满足条件的10星以下「武装龙」怪兽。
		local g=Duel.SelectMatchingCard(tp,c94141712.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选中的怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 效果③的发动条件（Condition）函数：检查这张卡是否作为龙族怪兽发动效果的代价而被送去墓地。
function c94141712.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		-- 检查触发该连锁的效果发动怪兽的种族是否为龙族。
		and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE)&RACE_DRAGON>0
end
-- 过滤卡组中可以加入手牌的「武装龙」卡片。
function c94141712.thfilter(c)
	return c:IsSetCard(0x111) and c:IsAbleToHand()
end
-- 效果③的靶向（Target）处理函数：检查卡组中是否存在可检索的「武装龙」卡，并设置操作信息。
function c94141712.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张「武装龙」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c94141712.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从卡组将1张卡加入手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理（Operation）函数：从卡组选择1张「武装龙」卡加入手牌并给对方确认。
function c94141712.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「武装龙」卡。
	local g=Duel.SelectMatchingCard(tp,c94141712.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
