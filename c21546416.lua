--アームド・ドラゴン・サンダー LV5
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「武装龙 LV5」使用。
-- ②：从手卡把1只怪兽送去墓地才能发动。场上的这张卡送去墓地，从手卡·卡组把1只7星以下的「武装龙」怪兽特殊召唤。
-- ③：这张卡为让龙族怪兽的效果发动而被送去墓地的场合才能发动。从卡组把1只5星以上的龙族·风属性怪兽加入手卡。
function c21546416.initial_effect(c)
	-- 使该卡在场上或墓地时视为「武装龙 LV5」使用
	aux.EnableChangeCode(c,46384672,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：从手卡把1只怪兽送去墓地才能发动。场上的这张卡送去墓地，从手卡·卡组把1只7星以下的「武装龙」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21546416,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21546416)
	e2:SetCost(c21546416.spcost)
	e2:SetTarget(c21546416.sptg)
	e2:SetOperation(c21546416.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡为让龙族怪兽的效果发动而被送去墓地的场合才能发动。从卡组把1只5星以上的龙族·风属性怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21546416,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,21546417)
	e3:SetCondition(c21546416.thcon)
	e3:SetTarget(c21546416.thtg)
	e3:SetOperation(c21546416.thop)
	c:RegisterEffect(e3)
end
c21546416.lvup={46384672}
c21546416.lvdn={57030525}
-- 定义costfilter函数，用于检查手牌中是否有可作为cost送入墓地的怪兽，并且后续能检索符合条件的特殊召唤怪兽
function c21546416.costfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 检查手牌和卡组中是否存在满足spfilter条件的怪兽
		and Duel.IsExistingMatchingCard(c21546416.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp,e:GetLabel())
end
-- 检查手牌中是否存在满足costfilter条件的怪兽
function c21546416.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if c:IsCode(46384672) then
			e:SetLabel(1)
		else
			e:SetLabel(0)
		end
		-- 提示玩家选择一张怪兽送入墓地作为发动cost
		return Duel.IsExistingMatchingCard(c21546416.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足costfilter条件的怪兽送入墓地
	local g=Duel.SelectMatchingCard(tp,c21546416.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的怪兽送入墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义spfilter函数，用于筛选7星以下的「武装龙」怪兽，或特定情况下可特殊召唤的「武装龙·雷电 LV5」
function c21546416.spfilter(c,e,tp,label)
	return c:IsSetCard(0x111) and c:IsLevelBelow(7)
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or label==1 and c:IsCode(73879377) and c:IsCanBeSpecialSummoned(e,0,tp,true,false))
end
-- 设置效果的发动条件，检查是否满足特殊召唤的条件
function c21546416.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if c:IsCode(46384672) then
			e:SetLabel(1)
		else
			e:SetLabel(0)
		end
		-- 检查该卡是否能被送去墓地且场上存在可用怪兽区
		return c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c)>0
			-- 检查手牌和卡组中是否存在满足spfilter条件的怪兽
			and Duel.IsExistingMatchingCard(c21546416.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,e:GetLabel())
	end
	-- 设置操作信息，表示将该卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
	-- 设置操作信息，表示将1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 定义效果的处理函数，执行特殊召唤操作
function c21546416.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该卡是否有效且能被送去墓地，且场上存在可用怪兽区
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0 then
		local label=e:GetLabel()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足spfilter条件的怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,c21546416.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,label)
		local tc=g:GetFirst()
		if tc then
			-- 如果满足特定条件则进行特殊召唤并完成程序
			if label==1 and tc:IsCode(73879377) and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)~=0 then
				tc:CompleteProcedure()
			else
				-- 执行普通特殊召唤
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 定义thcon函数，用于判断是否满足发动③效果的条件
function c21546416.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		-- 检查连锁中触发的效果是否为龙族怪兽效果
		and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE)&RACE_DRAGON>0
end
-- 定义thfilter函数，用于筛选5星以上、龙族、风属性的怪兽
function c21546416.thfilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToHand()
end
-- 设置效果的发动条件，检查是否满足检索条件
function c21546416.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足thfilter条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21546416.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将1只怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果的处理函数，执行检索并加入手牌操作
function c21546416.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足thfilter条件的怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,c21546416.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
