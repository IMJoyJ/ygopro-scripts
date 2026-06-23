--紅蓮薔薇の魔女
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。从卡组把1只「黑蔷薇之魔女」加入手卡，从卡组选1只3星以下的植物族怪兽在卡组最上面放置。那之后，可以从手卡把1只「黑蔷薇之魔女」召唤。
-- ②：把墓地的这张卡除外才能发动。从自己墓地的怪兽或者除外的自己怪兽之中选1只「黑蔷薇龙」或者「红莲蔷薇龙」回到额外卡组。
function c29107423.initial_effect(c)
	-- 记录此卡具有「黑蔷薇之魔女」的卡名
	aux.AddCodeList(c,73580471)
	-- ①：把这张卡解放才能发动。从卡组把1只「黑蔷薇之魔女」加入手卡，从卡组选1只3星以下的植物族怪兽在卡组最上面放置。那之后，可以从手卡把1只「黑蔷薇之魔女」召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29107423,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,29107423)
	e1:SetCost(c29107423.thcost)
	e1:SetTarget(c29107423.thtg)
	e1:SetOperation(c29107423.thop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己墓地的怪兽或者除外的自己怪兽之中选1只「黑蔷薇龙」或者「红莲蔷薇龙」回到额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29107423,1))
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,29107424)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c29107423.tetg)
	e2:SetOperation(c29107423.teop)
	c:RegisterEffect(e2)
end
-- 将此卡解放作为费用
function c29107423.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 实际执行将此卡解放的操作
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义检索过滤器：卡名是黑蔷薇之魔女且能加入手牌
function c29107423.thfilter(c,tp,solve)
	-- 卡名是黑蔷薇之魔女且能加入手牌，并且满足后续条件
	return c:IsCode(17720747) and c:IsAbleToHand() and (solve or Duel.IsExistingMatchingCard(c29107423.dtfilter,tp,LOCATION_DECK,0,1,c))
end
-- 定义放置卡组最上方的过滤器：等级3以下且种族为植物
function c29107423.dtfilter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_PLANT)
end
-- 设置效果目标：从卡组检索黑蔷薇之魔女并召唤
function c29107423.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c29107423.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,0,0,0)
end
-- 定义召唤过滤器：卡名是黑蔷薇之魔女且可通常召唤
function c29107423.sumfilter(c)
	return c:IsCode(17720747) and c:IsSummonable(true,nil)
end
-- 执行效果操作：检索黑蔷薇之魔女并放置植物族怪兽到卡组最上方，可选择召唤
function c29107423.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的黑蔷薇之魔女
	local g=Duel.SelectMatchingCard(tp,c29107423.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp,true)
	local tc=g:GetFirst()
	-- 确认卡已加入手牌
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
		-- 提示玩家选择要放置在卡组最上方的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(29107423,2))  --"请选择要放置在卡组最上面的卡"
		-- 选择满足条件的植物族怪兽
		local dg=Duel.SelectMatchingCard(tp,c29107423.dtfilter,tp,LOCATION_DECK,0,1,1,nil)
		local dc=dg:GetFirst()
		if dc then
			-- 洗切卡组
			Duel.ShuffleDeck(tp)
			-- 将所选怪兽移动到卡组最上方
			Duel.MoveSequence(dc,SEQ_DECKTOP)
			-- 确认卡组最上方的卡
			Duel.ConfirmDecktop(tp,1)
			-- 检查手牌是否有黑蔷薇之魔女并询问是否召唤
			if Duel.IsExistingMatchingCard(c29107423.sumfilter,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(29107423,3)) then  --"是否把「黑蔷薇之魔女」召唤？"
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 洗切手牌
				Duel.ShuffleHand(tp)
				-- 提示玩家选择要召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
				-- 选择满足条件的黑蔷薇之魔女
				local sg=Duel.SelectMatchingCard(tp,c29107423.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
				local sc=sg:GetFirst()
				if sc then
					-- 执行召唤操作
					Duel.Summon(tp,sc,true,nil)
				end
			end
		end
	end
end
-- 定义返回额外卡组的过滤器：卡名是黑蔷薇龙或红莲蔷薇龙且在墓地或除外状态
function c29107423.tefilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCode(73580471,40139997) and c:IsAbleToExtra()
end
-- 设置效果目标：将符合条件的怪兽返回额外卡组
function c29107423.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足返回额外卡组的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c29107423.tefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler()) end
	-- 设置操作信息：将怪兽返回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 执行效果操作：选择并返回符合条件的怪兽到额外卡组
function c29107423.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c29107423.tefilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选怪兽返回卡组并洗切
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
