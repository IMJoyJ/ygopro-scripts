--神速召喚
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段以及战斗阶段才能发动。把1只10星怪兽召唤。自己场上有「王后骑士」「卫兵骑士」「国王骑士」全部存在的场合，可以作为代替让以下效果适用。
-- ●从卡组把1只暗属性以外的攻击力?的10星怪兽加入手卡。那之后，可以把1只10星怪兽召唤。
function c55557574.initial_effect(c)
	-- 将「王后骑士」、「卫兵骑士」、「国王骑士」的卡片密码注册到本卡的关联卡片列表中。
	aux.AddCodeList(c,25652259,64788463,90876561)
	-- ①：自己·对方的主要阶段以及战斗阶段才能发动。把1只10星怪兽召唤。自己场上有「王后骑士」「卫兵骑士」「国王骑士」全部存在的场合，可以作为代替让以下效果适用。●从卡组把1只暗属性以外的攻击力?的10星怪兽加入手卡。那之后，可以把1只10星怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START)
	e1:SetCountLimit(1,55557574+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c55557574.condition)
	e1:SetTarget(c55557574.target)
	e1:SetOperation(c55557574.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：自己或对方的主要阶段以及战斗阶段。
function c55557574.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- 过滤条件：场上表侧表示的「王后骑士」、「卫兵骑士」或「国王骑士」。
function c55557574.checkfilter(c)
	return c:IsFaceup() and c:IsCode(64788463,25652259,90876561)
end
-- 过滤条件：可以进行通常召唤的10星怪兽。
function c55557574.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsLevel(10)
end
-- 过滤条件：卡组中暗属性以外、攻击力为?（在脚本中表示为-2）的10星怪兽。
function c55557574.thfilter(c)
	return c:GetTextAttack()==-2 and c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and c:IsLevel(10) and c:IsNonAttribute(ATTRIBUTE_DARK)
end
-- 效果发动时的合法性检查（Target）。
function c55557574.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上符合三骑士过滤条件的卡片组。
	local g=Duel.GetMatchingGroup(c55557574.checkfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查手牌或场上是否存在可以召唤的10星怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c55557574.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		-- 或者自己场上集齐三骑士，且卡组中存在可检索的怪兽。
		or (g:GetClassCount(Card.GetCode)==3 and Duel.IsExistingMatchingCard(c55557574.thfilter,tp,LOCATION_DECK,0,1,nil)) end
end
-- 效果处理（Operation）。
function c55557574.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上符合三骑士过滤条件的卡片组。
	local g=Duel.GetMatchingGroup(c55557574.checkfilter,tp,LOCATION_MZONE,0,nil)
	local check1=g:GetClassCount(Card.GetCode)==3
	-- 检查手牌或场上是否存在可以召唤的10星怪兽。
	local check2=Duel.IsExistingMatchingCard(c55557574.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
	-- 如果自己场上集齐三骑士，且卡组中存在可检索的怪兽。
	if check1 and Duel.IsExistingMatchingCard(c55557574.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 并且在无法直接召唤，或者玩家选择适用代替效果时。
		and (not check2 or Duel.SelectYesNo(tp,aux.Stringid(55557574,1))) then  --"是否从卡组把10星怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1只满足检索条件的怪兽。
		local g=Duel.SelectMatchingCard(tp,c55557574.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选择的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
		-- 检查手牌或场上是否存在可以召唤的10星怪兽。
		if Duel.IsExistingMatchingCard(c55557574.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
			-- 询问玩家是否进行10星怪兽的召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(55557574,2)) then  --"是否把10星怪兽召唤？"
			-- 中断当前效果，使之后的效果处理（召唤）视为不同时处理。
			Duel.BreakEffect()
			-- 洗切玩家的手牌。
			Duel.ShuffleHand(tp)
			-- 提示玩家选择要召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 从手牌或场上选择1只可以召唤的10星怪兽。
			local sg=Duel.SelectMatchingCard(tp,c55557574.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
			-- 将选择的怪兽进行通常召唤。
			Duel.Summon(tp,sg:GetFirst(),true,nil)
		end
	elseif check2 then
		-- 提示玩家选择要召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
		-- 从手牌或场上选择1只可以召唤的10星怪兽。
		local g=Duel.SelectMatchingCard(tp,c55557574.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选择的怪兽进行通常召唤。
			Duel.Summon(tp,tc,true,nil)
		end
	end
end
