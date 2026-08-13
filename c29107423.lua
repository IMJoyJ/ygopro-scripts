--紅蓮薔薇の魔女
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。从卡组把1只「黑蔷薇之魔女」加入手卡，从卡组选1只3星以下的植物族怪兽在卡组最上面放置。那之后，可以从手卡把1只「黑蔷薇之魔女」召唤。
-- ②：把墓地的这张卡除外才能发动。从自己墓地的怪兽或者除外的自己怪兽之中选1只「黑蔷薇龙」或者「红莲蔷薇龙」回到额外卡组。
function c29107423.initial_effect(c)
	-- 向卡片注册“黑蔷薇龙”(73580471)的卡名信息，使该卡被视为记载了“黑蔷薇龙”的卡，用于相关规则判定。
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
	-- 设定②效果的发动代价为“把这张卡除外”（aux.bfgcost是除外自身作为cost的通用写法）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c29107423.tetg)
	e2:SetOperation(c29107423.teop)
	c:RegisterEffect(e2)
end
-- 定义①效果的代价函数：在chk==0时检查此卡是否可以被解放作为代价；确认后执行解放动作。
function c29107423.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡以“解放”的形式作为代价送入墓地（REASON_COST），完成①效果的cost支付。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义检索「黑蔷薇之魔女」的过滤条件：必须是可以加入手卡的「黑蔷薇之魔女」(17720747)，且在发动检查阶段还需确认卡组中存在1只3星以下的植物族怪兽，以保证后续处理能够完成。
function c29107423.thfilter(c,tp,solve)
	-- 过滤条件核心：卡号17720747且可加入手卡；当solve为false（即发动可行性检查）时，额外要求卡组中存在合适的植物族怪兽（dtfilter）。
	return c:IsCode(17720747) and c:IsAbleToHand() and (solve or Duel.IsExistingMatchingCard(c29107423.dtfilter,tp,LOCATION_DECK,0,1,c))
end
-- 定义植物族怪兽的过滤条件：等级3以下且种族为植物族。
function c29107423.dtfilter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_PLANT)
end
-- 定义①效果的发动条件：卡组中存在符合条件的「黑蔷薇之魔女」即可发动；同时设置操作信息，标记将进行检索加入手卡以及可能进行的召唤。
function c29107423.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查（chk==0）时，确认卡组中存在至少1张满足thfilter条件的「黑蔷薇之魔女」；否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c29107423.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：本效果会从卡组把1张卡加入手卡（CATEGORY_TOHAND），用于让相关效果正确响应检索。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：本效果后续可能进行通常召唤（CATEGORY_SUMMON），用于让相关效果正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,0,0,0)
end
-- 定义「黑蔷薇之魔女」的召唤条件过滤器：卡号17720747，且当前可以无视召唤次数限制进行通常召唤。
function c29107423.sumfilter(c)
	return c:IsCode(17720747) and c:IsSummonable(true,nil)
end
-- 定义①效果的处理流程：选择并加入手卡1只「黑蔷薇之魔女」，展示给对手；再从卡组选1只3星以下植物族怪兽放到卡组顶；最后询问是否额外召唤手卡中的「黑蔷薇之魔女」。
function c29107423.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示文字，进入选择卡牌界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足thfilter的「黑蔷薇之魔女」（此时solve=true，表示处理阶段不再额外检查植物族是否存在）。
	local g=Duel.SelectMatchingCard(tp,c29107423.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp,true)
	local tc=g:GetFirst()
	-- 判断「黑蔷薇之魔女」是否成功加入手卡：如果送入手卡结果不为0且该卡仍在手卡，才继续执行后续步骤。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 将加入手卡的「黑蔷薇之魔女」展示给对手确认。
		Duel.ConfirmCards(1-tp,tc)
		-- 显示“请选择要放置在卡组最上面的卡”的提示文字，进入选择卡牌界面。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(29107423,2))  --"请选择要放置在卡组最上面的卡"
		-- 从卡组选择1张3星以下的植物族怪兽（dtfilter）用于放置到卡组最上方。
		local dg=Duel.SelectMatchingCard(tp,c29107423.dtfilter,tp,LOCATION_DECK,0,1,1,nil)
		local dc=dg:GetFirst()
		if dc then
			-- 洗切卡组，因为前面进行过检索，卡组顺序已改变，需要洗牌后再将卡片放到顶部。
			Duel.ShuffleDeck(tp)
			-- 把选中的植物族怪兽移动到卡组最上方（SEQ_DECKTOP）。
			Duel.MoveSequence(dc,SEQ_DECKTOP)
			-- 确认己方卡组最上方1张卡，即确认刚放置到顶部的卡。
			Duel.ConfirmDecktop(tp,1)
			-- 检查手牌中是否存在可以通常召唤的「黑蔷薇之魔女」，存在则询问玩家是否进行召唤。
			if Duel.IsExistingMatchingCard(c29107423.sumfilter,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(29107423,3)) then  --"是否把「黑蔷薇之魔女」召唤？"
				-- 中断当前效果链，使后续的召唤处理与前序处理分开，避免占用同一时点导致其他效果无法响应。
				Duel.BreakEffect()
				-- 洗切手牌，使手牌顺序随机化后再选择要召唤的卡。
				Duel.ShuffleHand(tp)
				-- 显示“请选择要召唤的卡”的提示文字。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
				-- 从手卡选择1只满足sumfilter的「黑蔷薇之魔女」。
				local sg=Duel.SelectMatchingCard(tp,c29107423.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
				local sc=sg:GetFirst()
				if sc then
					-- 将选中的「黑蔷薇之魔女」通常召唤到场上，忽略本回合通常召唤次数限制（true）。
					Duel.Summon(tp,sc,true,nil)
				end
			end
		end
	end
end
-- 定义②效果的过滤器：选择对象为墓地中的怪兽，或表侧表示的除外区怪兽，卡号为73580471（黑蔷薇龙）或40139997（红莲蔷薇龙），并且可以回到额外卡组。
function c29107423.tefilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCode(73580471,40139997) and c:IsAbleToExtra()
end
-- 定义②效果的发动条件：墓地或我方除外区存在符合条件的「黑蔷薇龙／红莲蔷薇龙」，且不能选择效果发动者本身；设置操作信息为返回额外卡组。
function c29107423.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查时，确认墓地·除外区存在至少1张符合条件的龙族怪兽（除自身外）。
	if chk==0 then return Duel.IsExistingMatchingCard(c29107423.tefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler()) end
	-- 设置操作信息：本效果将把1张卡从墓地或除外区返回额外卡组（CATEGORY_TOEXTRA）。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 定义②效果的处理：选择1张符合条件的「黑蔷薇龙」或「红莲蔷薇龙」，将其返回持有者的额外卡组。
function c29107423.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要返回卡组的卡”的提示文字（此处实际返回额外卡组，但沿用“返回卡组”的提示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从墓地/除外区选择1张符合条件的龙族怪兽，同时适用王家长眠之谷的过滤（若存在相关环境效果则不能选择受影响的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c29107423.tefilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽返回持有者额外卡组（REASON_EFFECT作为效果处理原因）。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
