--絶望と希望の逆転
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有天使族·地属性怪兽3只以上存在的场合才能发动。场上的怪兽全部送去墓地。那之后，双方可以从对方墓地选最多有被这个效果各送去对方墓地的怪兽数量的怪兽在自身场上特殊召唤。自己墓地有「现世与冥界的逆转」存在的场合，再让自己可以从卡组选1张陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
function c25209168.initial_effect(c)
	-- 记录此卡与「现世与冥界的逆转」的关联
	aux.AddCodeList(c,17484499)
	-- ①：自己场上有天使族·地属性怪兽3只以上存在的场合才能发动。场上的怪兽全部送去墓地。那之后，双方可以从对方墓地选最多有被这个效果各送去对方墓地的怪兽数量的怪兽在自身场上特殊召唤。自己墓地有「现世与冥界的逆转」存在的场合，再让自己可以从卡组选1张陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25209168,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,25209168+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c25209168.condition)
	e1:SetTarget(c25209168.target)
	e1:SetOperation(c25209168.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否为天使族地属性的正面表示怪兽
function c25209168.cfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceup()
end
-- 判断自己场上是否存在至少3只天使族地属性的正面表示怪兽
function c25209168.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在至少3只天使族地属性的正面表示怪兽
	return Duel.IsExistingMatchingCard(c25209168.cfilter,tp,LOCATION_MZONE,0,3,nil)
end
-- 设置效果处理时的条件检查，确认场上存在至少1只怪兽
function c25209168.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 设置效果处理时的条件检查，确认场上存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，表示将场上所有怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果处理函数，执行将场上怪兽送去墓地、特殊召唤对方墓地怪兽、以及可能的陷阱卡盖放
function c25209168.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 获取当前回合玩家
	local p=Duel.GetTurnPlayer()
	local g1=g:Filter(Card.IsControler,nil,p)
	local g2=g:Filter(Card.IsControler,nil,1-p)
	-- 将场上所有怪兽送去墓地
	if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
	-- 获取当前回合玩家的怪兽区域可用空位数
	local ft1=Duel.GetLocationCount(p,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft1>1 and Duel.IsPlayerAffectedByEffect(p,59822133) then ft1=1 end
	local ct1=g:FilterCount(c25209168.ctfilter,nil,1-p)
	if ct1>ft1 then ct1=ft1 end
	-- 获取非当前回合玩家的怪兽区域可用空位数
	local ft2=Duel.GetLocationCount(1-p,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft2>1 and Duel.IsPlayerAffectedByEffect(1-p,59822133) then ft2=1 end
	local ct2=g1:FilterCount(c25209168.ctfilter,nil,p)
	if ct2>ft2 then ct2=ft2 end
	-- 获取当前回合玩家可特殊召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),p,0,LOCATION_GRAVE,nil,e,0,p,false,false)
	-- 获取非当前回合玩家可特殊召唤的怪兽组
	local sg2=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),1-p,0,LOCATION_GRAVE,nil,e,0,1-p,false,false)
	local tg1=Group.CreateGroup()
	local tg2=Group.CreateGroup()
	-- 判断当前回合玩家是否可以选择从对方墓地特殊召唤怪兽
	if ft1>0 and sg1:GetCount()>0 and Duel.SelectYesNo(p,aux.Stringid(25209168,1)) then  --"是否从对方墓地选怪兽特殊召唤？"
		-- 提示当前回合玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		tg1=sg1:Select(p,1,ct1,nil)
		-- 显示当前回合玩家选择的怪兽作为特殊召唤对象
		Duel.HintSelection(tg1)
	end
	-- 判断非当前回合玩家是否可以选择从对方墓地特殊召唤怪兽
	if ft2>0 and sg2:GetCount()>0 and Duel.SelectYesNo(1-p,aux.Stringid(25209168,1)) then  --"是否从对方墓地选怪兽特殊召唤？"
		-- 提示非当前回合玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,1-p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		tg2=sg2:Select(1-p,1,ct2,nil)
		-- 显示非当前回合玩家选择的怪兽作为特殊召唤对象
		Duel.HintSelection(tg2)
	end
	if tg1:GetCount()>0 or tg2:GetCount()>0 then
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 遍历当前回合玩家选择的特殊召唤怪兽组
		for sc1 in aux.Next(tg1) do
			-- 将当前回合玩家选择的怪兽特殊召唤
			Duel.SpecialSummonStep(sc1,0,p,p,false,false,POS_FACEUP)
		end
		-- 遍历非当前回合玩家选择的特殊召唤怪兽组
		for sc2 in aux.Next(tg2) do
			-- 将非当前回合玩家选择的怪兽特殊召唤
			Duel.SpecialSummonStep(sc2,0,1-p,1-p,false,false,POS_FACEUP)
		end
		-- 完成所有特殊召唤步骤
		Duel.SpecialSummonComplete()
		-- 获取卡组中可盖放的陷阱卡组
		local stg=Duel.GetMatchingGroup(c25209168.stfilter,tp,LOCATION_DECK,0,nil)
		-- 判断自己墓地是否存在「现世与冥界的逆转」
		if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,17484499) and stg:GetCount()>0
			-- 询问当前回合玩家是否从卡组选择陷阱卡盖放
			and Duel.SelectYesNo(tp,aux.Stringid(25209168,2)) then  --"是否从卡组选陷阱卡盖放？"
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 提示当前回合玩家选择要盖放的陷阱卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local tc=stg:Select(tp,1,1,nil):GetFirst()
			-- 将选择的陷阱卡盖放到场上
			if tc and Duel.SSet(tp,tc)~=0 then
				-- 使盖放的陷阱卡在盖放回合也能发动
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(25209168,3))  --"适用「绝望与希望的逆转」的效果来发动"
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end
-- 过滤函数，用于判断是否为对方墓地的怪兽
function c25209168.ctfilter(c,p)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(p) and c:IsType(TYPE_MONSTER)
end
-- 过滤函数，用于判断是否为可盖放的陷阱卡
function c25209168.stfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
