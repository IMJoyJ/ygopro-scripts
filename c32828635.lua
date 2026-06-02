--エンドレス・オブ・ザ・ワールド
-- 效果：
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己场上的怪兽解放，从手卡把「破灭之女神 露茵」或「终焉之王 迪米斯」仪式召唤。
-- ②：让这个回合没有送去墓地的这张卡从墓地回到卡组才能发动。从卡组把1张「世界末日」加入手卡。那之后，可以从自己墓地把1只「破灭之女神 露茵」或「终焉之王 迪米斯」加入手卡。
function c32828635.initial_effect(c)
	-- 注册卡片密码8198712（世界末日）、46427957（破灭之女神 露茵）、72426662（终焉之王 迪米斯）至当前卡片的记载卡密码列表中。
	aux.AddCodeList(c,8198712,46427957,72426662)
	-- 为卡片添加仪式召唤的处理效果，该仪式召唤仅允许从手卡召唤「破灭之女神 露茵」或「终焉之王 迪米斯」。
	aux.AddRitualProcGreater2Code2(c,46427957,72426662,nil,nil,c32828635.mfilter)
	-- ②：让这个回合没有送去墓地的这张卡从墓地回到卡组才能发动。从卡组把1张「世界末日」加入手卡。那之后，可以从自己墓地把1只「破灭之女神 露茵」或「终焉之王 迪米斯」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32828635,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置效果发动条件为此卡送去墓地的回合不能发动。
	e2:SetCondition(aux.exccon)
	e2:SetCost(c32828635.thcost)
	e2:SetTarget(c32828635.thtg)
	e2:SetOperation(c32828635.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于仪式召唤解放素材时，筛选不是手牌的卡片（即只能从场上解放怪兽）。
function c32828635.mfilter(c)
	return not c:IsLocation(LOCATION_HAND)
end
-- 效果发动的代价，让此卡回到卡组。
function c32828635.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	-- 将作为代价发动的此卡送回卡组并洗牌。
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤函数，筛选卡组中的「世界末日」且可以加入手卡。
function c32828635.filter(c)
	return c:IsCode(8198712) and c:IsAbleToHand()
end
-- 过滤函数，筛选墓地中的「破灭之女神 露茵」或「终焉之王 迪米斯」且可以加入手卡。
function c32828635.filter2(c)
	return c:IsCode(46427957,72426662) and c:IsAbleToHand()
end
-- 效果发动的目标，确认卡组中存在可以加入手牌的「世界末日」，并设置操作信息。
function c32828635.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张满足条件的「世界末日」。
	if chk==0 then return Duel.IsExistingMatchingCard(c32828635.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的具体处理逻辑：从卡组把1张「世界末日」加入手卡。那之后，可以从自己墓地把1只「破灭之女神 露茵」或「终焉之王 迪米斯」加入手卡。
function c32828635.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「世界末日」。
	local g=Duel.SelectMatchingCard(tp,c32828635.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片送入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
		-- 获取自己墓地中满足过滤条件且不受王家长眠之谷影响的「破灭之女神 露茵」或「终焉之王 迪米斯」。
		local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c32828635.filter2),tp,LOCATION_GRAVE,0,nil)
		-- 若墓地存在可回收卡片且玩家选择发动效果，则继续处理。
		if mg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(32828635,1)) then  --"是否回收卡片？"
			-- 中断效果，使之后的效果处理与之前的效果处理不视为同时进行。
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=mg:Select(tp,1,1,nil)
			-- 将从墓地选择的卡片送入玩家手卡。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 给对方玩家确认从墓地回收的卡片。
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
