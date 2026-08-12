--アームド・ドラゴン・サンダー LV3
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「武装龙 LV3」使用。
-- ②：从手卡把1只怪兽送去墓地才能发动。场上的这张卡送去墓地，从手卡·卡组把1只5星以下的「武装龙」怪兽特殊召唤。
-- ③：这张卡为让龙族怪兽的效果发动而被送去墓地的场合才能发动。自己从卡组抽1张。
function c57030525.initial_effect(c)
	-- 使这张卡在怪兽区域和墓地存在时，卡名当作「武装龙 LV3」使用。
	aux.EnableChangeCode(c,980973,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：从手卡把1只怪兽送去墓地才能发动。场上的这张卡送去墓地，从手卡·卡组把1只5星以下的「武装龙」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57030525,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,57030525)
	e2:SetCost(c57030525.spcost)
	e2:SetTarget(c57030525.sptg)
	e2:SetOperation(c57030525.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡为让龙族怪兽的效果发动而被送去墓地的场合才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(57030525,1))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,57030526)
	e3:SetCondition(c57030525.drcon)
	e3:SetTarget(c57030525.drtg)
	e3:SetOperation(c57030525.drop)
	c:RegisterEffect(e3)
end
c57030525.lvup={980973}
-- 过滤作为发动代价送去墓地的手牌怪兽，该怪兽必须能送去墓地，且此时手牌或卡组中存在可特殊召唤的5星以下「武装龙」怪兽。
function c57030525.costfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 检查手牌或卡组中是否存在至少1只满足特殊召唤条件的5星以下「武装龙」怪兽（排除当前作为代价的卡）。
		and Duel.IsExistingMatchingCard(c57030525.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp)
end
-- 效果②的发动代价处理函数：从手牌选择1只怪兽送去墓地。
function c57030525.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可作为发动代价送去墓地的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c57030525.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手牌中1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c57030525.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的怪兽作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤满足特殊召唤条件的5星以下「武装龙」怪兽。
function c57030525.spfilter(c,e,tp)
	return c:IsSetCard(0x111) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（Target）函数：检查自身是否能送去墓地、是否有可用怪兽区域以及是否有可特召的怪兽，并设置操作信息。
function c57030525.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身是否能送去墓地，以及自身离开场上后是否有可用的怪兽区域。
	if chk==0 then return c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c)>0
		-- 检查手牌或卡组中是否存在可特殊召唤的5星以下「武装龙」怪兽。
		and Duel.IsExistingMatchingCard(c57030525.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：将自身（1张卡）送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
	-- 设置效果处理信息：从手牌或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的效果处理（Operation）函数：将自身送去墓地，并从手牌或卡组特殊召唤1只5星以下「武装龙」怪兽。
function c57030525.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关，若成功将自身送去墓地且自身确实存在于墓地，且此时有可用的怪兽区域，则继续处理。
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从手牌或卡组选择1只满足条件的「武装龙」怪兽。
		local g=Duel.SelectMatchingCard(tp,c57030525.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 效果③的发动条件判断函数：检查自身是否作为发动怪兽效果的代价被送去墓地，且该效果的发动者为龙族怪兽。
function c57030525.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		-- 检查触发该连锁的效果发动怪兽的种族是否为龙族。
		and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE)&RACE_DRAGON>0
end
-- 效果③的发动准备（Target）函数：检查玩家是否能抽卡，并设置抽卡相关的目标玩家、参数和操作信息。
function c57030525.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以从卡组抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前效果的目标玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置当前效果的目标参数为1（抽1张卡）。
	Duel.SetTargetParam(1)
	-- 设置效果处理信息：自己从卡组抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果③的效果处理（Operation）函数：执行抽卡。
function c57030525.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果设定的目标玩家和抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
