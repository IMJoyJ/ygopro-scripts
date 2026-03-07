--武神集結
-- 效果：
-- 自己场上没有这张卡以外的卡存在的场合才能发动。自己墓地的名字带有「武神」的兽战士族怪兽全部回到卡组，自己手卡全部送去墓地。那之后，可以从卡组把最多3只卡名不同的名字带有「武神」的兽战士族怪兽加入手卡。「武神集结」在1回合只能发动1张。
function c33611061.initial_effect(c)
	-- 效果定义：将此卡注册为发动时点为自由连锁的魔法卡，且只能发动一次，条件为己方场上没有此卡以外的卡，目标为己方墓地的兽战士族武神怪兽，操作为将这些怪兽送回卡组并丢弃手牌，之后从卡组检索最多3只不同名的武神兽战士族怪兽加入手牌
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_HANDES+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,33611061+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c33611061.condition)
	e1:SetTarget(c33611061.target)
	e1:SetOperation(c33611061.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：己方场上没有此卡以外的卡存在
function c33611061.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果条件：己方场上没有此卡以外的卡存在
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- 过滤函数：筛选出名字带有「武神」且为兽战士族且能送回卡组的怪兽
function c33611061.filter(c)
	return c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR) and c:IsAbleToDeck()
end
-- 效果目标：检查己方墓地是否存在满足条件的怪兽，若存在则将这些怪兽设置为送回卡组的操作信息
function c33611061.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果目标：检查己方墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c33611061.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 获取满足条件的怪兽组：从己方墓地获取所有名字带有「武神」且为兽战士族且能送回卡组的怪兽
	local g=Duel.GetMatchingGroup(c33611061.filter,tp,LOCATION_GRAVE,0,nil)
	-- 设置操作信息：将这些怪兽设置为送回卡组的效果
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 过滤函数：筛选出名字带有「武神」且为兽战士族且能加入手牌的怪兽
function c33611061.thfilter(c)
	return c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR) and c:IsAbleToHand()
end
-- 效果发动：获取己方墓地满足条件的怪兽组，若无王家长眠之谷无效则将这些怪兽送回卡组并丢弃手牌，然后从卡组检索最多3只不同名的武神兽战士族怪兽加入手牌
function c33611061.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的怪兽组：从己方墓地获取所有名字带有「武神」且为兽战士族且能送回卡组的怪兽
	local tg=Duel.GetMatchingGroup(c33611061.filter,tp,LOCATION_GRAVE,0,nil)
	-- 检查王家长眠之谷：若存在王家长眠之谷则无效此效果
	if aux.NecroValleyNegateCheck(tg) then return end
	if tg:GetCount()>0 then
		-- 将怪兽送回卡组：将满足条件的怪兽全部送回卡组并洗牌
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 获取手牌组：获取己方手牌
		local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		-- 将手牌送入墓地：将己方手牌全部送入墓地
		Duel.SendtoGrave(hg,REASON_EFFECT)
		-- 中断效果处理：使后续效果处理视为错时点
		Duel.BreakEffect()
		-- 获取卡组中满足条件的怪兽组：从己方卡组获取所有名字带有「武神」且为兽战士族且能加入手牌的怪兽
		local g=Duel.GetMatchingGroup(c33611061.thfilter,tp,LOCATION_DECK,0,nil)
		if g:GetCount()==0 then return end
		-- 提示选择：提示己方选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的怪兽组：从卡组中选择最多3只不同名的武神兽战士族怪兽
		local g1=g:SelectSubGroup(tp,aux.dncheck,false,1,3)
		-- 将怪兽加入手牌：将选中的怪兽加入手牌
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		-- 确认手牌：向对方确认加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g1)
	end
end
