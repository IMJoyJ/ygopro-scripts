--エンドレス・オブ・ザ・ワールド
-- 效果：
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己场上的怪兽解放，从手卡把「破灭之女神 露茵」或「终焉之王 迪米斯」仪式召唤。
-- ②：让这个回合没有送去墓地的这张卡从墓地回到卡组才能发动。从卡组把1张「世界末日」加入手卡。那之后，可以从自己墓地把1只「破灭之女神 露茵」或「终焉之王 迪米斯」加入手卡。
function c32828635.initial_effect(c)
	-- 注册一个只能通过指定的两张仪式魔法卡来发动的仪式召唤效果，且只能通过特定的怪兽作为素材进行仪式召唤
	aux.AddRitualProcGreater2Code2(c,46427957,72426662,nil,nil,c32828635.mfilter)
	-- ②：让这个回合没有送去墓地的这张卡从墓地回到卡组才能发动。从卡组把1张「世界末日」加入手卡。那之后，可以从自己墓地把1只「破灭之女神 露茵」或「终焉之王 迪米斯」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32828635,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置效果的发动条件为：这张卡在本回合没有被送去墓地
	e2:SetCondition(aux.exccon)
	e2:SetCost(c32828635.thcost)
	e2:SetTarget(c32828635.thtg)
	e2:SetOperation(c32828635.thop)
	c:RegisterEffect(e2)
end
-- 定义一个过滤函数，用于排除手牌位置的怪兽，只允许场上怪兽参与仪式召唤
function c32828635.mfilter(c)
	return not c:IsLocation(LOCATION_HAND)
end
-- 定义效果的发动费用函数，将自身送入卡组作为费用
function c32828635.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	-- 将自身送入卡组并洗牌作为发动费用
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 定义一个过滤函数，用于检索卡组中「世界末日」卡片
function c32828635.filter(c)
	return c:IsCode(8198712) and c:IsAbleToHand()
end
-- 定义一个过滤函数，用于检索墓地中「破灭之女神 露茵」或「终焉之王 迪米斯」卡片
function c32828635.filter2(c)
	return c:IsCode(46427957,72426662) and c:IsAbleToHand()
end
-- 设置效果的发动目标函数，检查卡组中是否存在「世界末日」
function c32828635.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少一张「世界末日」
	if chk==0 then return Duel.IsExistingMatchingCard(c32828635.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的操作信息，表示将从卡组检索一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果的发动处理函数，执行检索和回收操作
function c32828635.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张「世界末日」加入手牌
	local g=Duel.SelectMatchingCard(tp,c32828635.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「世界末日」加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 从墓地中检索满足条件的「破灭之女神 露茵」或「终焉之王 迪米斯」卡片
		local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c32828635.filter2),tp,LOCATION_GRAVE,0,nil)
		-- 判断是否有满足条件的卡片可回收，并询问玩家是否发动
		if mg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(32828635,1)) then  --"是否回收卡片？"
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 向玩家提示选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=mg:Select(tp,1,1,nil)
			-- 将选中的「破灭之女神 露茵」或「终焉之王 迪米斯」加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
