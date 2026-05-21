--暗岩の海竜神
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1张表侧表示的「海」送去墓地才能发动。从自己的手卡·卡组把有「海」的卡名记述的怪兽或者水属性通常怪兽合计最多2只守备表示特殊召唤（同名卡最多1张）。对方场上有怪兽存在的场合，可以再从手卡·卡组把6星以下的水属性通常怪兽任意数量特殊召唤。这张卡的发动后，直到下次的自己回合的结束时自己不是水属性怪兽不能特殊召唤。
function c95602345.initial_effect(c)
	-- 注册卡片效果中记述了「海」的卡片信息
	aux.AddCodeList(c,22702055)
	-- ①：把自己场上1张表侧表示的「海」送去墓地才能发动。从自己的手卡·卡组把有「海」的卡名记述的怪兽或者水属性通常怪兽合计最多2只守备表示特殊召唤（同名卡最多1张）。对方场上有怪兽存在的场合，可以再从手卡·卡组把6星以下的水属性通常怪兽任意数量特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,95602345+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c95602345.cost)
	e1:SetTarget(c95602345.target)
	e1:SetOperation(c95602345.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示且可以送去墓地的「海」
function c95602345.cfilter(c)
	return c:IsCode(22702055) and c:IsAbleToGraveAsCost() and c:IsFaceup()
end
-- 效果发动的代价：将自己场上1张表侧表示的「海」送去墓地
function c95602345.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可以作为代价送去墓地的表侧表示的「海」
	if chk==0 then return Duel.IsExistingMatchingCard(c95602345.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1张表侧表示的「海」
	local g=Duel.SelectMatchingCard(tp,c95602345.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：手卡·卡组中记述了「海」的怪兽或水属性通常怪兽，且可以守备表示特殊召唤
function c95602345.spfilter(c,e,tp)
	-- 检查卡片是否记述了「海」或者是水属性通常怪兽
	return (aux.IsCodeListed(c,22702055) or (c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_WATER)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 过滤条件：手卡·卡组中6星以下的水属性通常怪兽，且可以特殊召唤
function c95602345.spfilter1(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标：检查怪兽区域是否有空位，以及手卡·卡组中是否存在可特殊召唤的符合条件的怪兽
function c95602345.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手卡或卡组中是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c95602345.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预计从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：从手卡·卡组特殊召唤最多2只符合条件的怪兽，若对方场上有怪兽，可再特殊召唤任意数量的6星以下水属性通常怪兽，并适用特殊召唤限制
function c95602345.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 计算当前可特殊召唤的最大数量（怪兽区域空位数与2的较小值）
	local ft=math.min(2,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	if ft>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 获取手卡和卡组中所有满足第一阶段特殊召唤条件的怪兽
		local tg=Duel.GetMatchingGroup(c95602345.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家选择最多ft张卡名互不相同的怪兽
		local g1=tg:SelectSubGroup(tp,aux.dncheck,false,1,ft)
		if g1 then
			-- 将选中的怪兽以表侧守备表示特殊召唤
			Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
		-- 获取特殊召唤后自己场上剩余的怪兽区域空位数
		local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取手卡和卡组中所有满足第二阶段特殊召唤条件的怪兽
		local g2=Duel.GetMatchingGroup(c95602345.spfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft1>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 检查自己场上是否有空位，且对方场上是否存在怪兽
		if ft1>0 and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil)
			-- 且存在可特殊召唤的怪兽时，询问玩家是否继续特殊召唤
			and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(95602345,0)) then  --"是否继续特殊召唤水属性通常怪兽？"
			-- 中断当前效果处理，使后续的特殊召唤与前一次特殊召唤不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local g3=g2:Select(tp,1,ft1,nil)
			if g3 then
				-- 将选中的怪兽以表侧表示特殊召唤
				Duel.SpecialSummon(g3,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下次的自己回合的结束时自己不是水属性怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c95602345.splimit)
		-- 判断当前回合玩家是否为自己，以确定限制效果的持续回合数
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		-- 在全局环境中注册该特殊召唤限制效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制条件：不能特殊召唤非水属性的怪兽
function c95602345.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
