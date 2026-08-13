--絶望と希望の逆転
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有天使族·地属性怪兽3只以上存在的场合才能发动。场上的怪兽全部送去墓地。那之后，双方可以从对方墓地选最多有被这个效果各送去对方墓地的怪兽数量的怪兽在自身场上特殊召唤。自己墓地有「现世与冥界的逆转」存在的场合，再让自己可以从卡组选1张陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
function c25209168.initial_effect(c)
	-- 将卡名记载「现世与冥界的逆转」的卡号17484499登记到当前卡片上，用于后续判断自己墓地是否存在该卡。
	aux.AddCodeList(c,17484499)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有天使族·地属性怪兽3只以上存在的场合才能发动。场上的怪兽全部送去墓地。那之后，双方可以从对方墓地选最多有被这个效果各送去对方墓地的怪兽数量的怪兽在自身场上特殊召唤。自己墓地有「现世与冥界的逆转」存在的场合，再让自己可以从卡组选1张陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
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
-- 定义过滤器：筛选表侧表示且种族为天使族、属性为地属性的怪兽，用于检查发动条件。
function c25209168.cfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceup()
end
-- 定义效果发动条件：自己场上有至少3只天使族·地属性表侧怪兽存在时才能发动。
function c25209168.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（仅主怪兽区）是否存在至少3只满足 cfilter 的天使族·地属性表侧怪兽，作为发动条件。
	return Duel.IsExistingMatchingCard(c25209168.cfilter,tp,LOCATION_MZONE,0,3,nil)
end
-- 定义发动时的目标选择处理：在 chk==0 时确认可行，然后获取场上全部怪兽，并将“场上怪兽全部送去墓地”的操作信息写入连锁。
function c25209168.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：场上必须存在至少1只怪兽，才能让“场上的怪兽全部送去墓地”这一处理成立。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得双方主怪兽区域存在的所有怪兽的集合，用于后续全部送去墓地。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置效果处理信息：将场上所有怪兽送去墓地，并登记其数量，供其他卡连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果处理：先把场上所有怪兽送去墓地；然后当前回合玩家和对方分别选择对方墓地中可特殊召唤的怪兽（数量受送去墓地的对方怪兽数量和可用区域限制）正面表示特殊召唤；若自己墓地有「现世与冥界的逆转」，再从卡组选1张陷阱卡盖放，并使其在盖放回合也能发动。
function c25209168.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取双方场上全部怪兽的集合，作为送入墓地处理的依据。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 取得当前回合玩家，用于区分“自己墓地”“对方墓地”以及特殊召唤的归属。
	local p=Duel.GetTurnPlayer()
	local g1=g:Filter(Card.IsControler,nil,p)
	local g2=g:Filter(Card.IsControler,nil,1-p)
	-- 将场上所有怪兽以效果原因送去墓地；如果没有任何卡被送去墓地则直接结束处理。
	if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
	-- 计算当前回合玩家 p 的主怪兽区可用空格数，用于限制 p 能特殊召唤的怪兽数量。
	local ft1=Duel.GetLocationCount(p,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft1>1 and Duel.IsPlayerAffectedByEffect(p,59822133) then ft1=1 end
	local ct1=g:FilterCount(c25209168.ctfilter,nil,1-p)
	if ct1>ft1 then ct1=ft1 end
	-- 计算对方玩家 1-p 的主怪兽区可用空格数，用于限制对方能特殊召唤的怪兽数量。
	local ft2=Duel.GetLocationCount(1-p,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft2>1 and Duel.IsPlayerAffectedByEffect(1-p,59822133) then ft2=1 end
	local ct2=g1:FilterCount(c25209168.ctfilter,nil,p)
	if ct2>ft2 then ct2=ft2 end
	-- 筛选对方墓地中可供当前回合玩家 p 特殊召唤的怪兽（不受王家长眠之谷影响的合法特殊召唤对象）。
	local sg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),p,0,LOCATION_GRAVE,nil,e,0,p,false,false)
	-- 筛选当前回合玩家墓地中可供对方玩家 1-p 特殊召唤的怪兽（不受王家长眠之谷影响的合法特殊召唤对象）。
	local sg2=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),1-p,0,LOCATION_GRAVE,nil,e,0,1-p,false,false)
	local tg1=Group.CreateGroup()
	local tg2=Group.CreateGroup()
	-- 若当前回合玩家 p 有可用区域且对方墓地有可选怪兽，则询问 p 是否从对方墓地选怪兽特殊召唤。
	if ft1>0 and sg1:GetCount()>0 and Duel.SelectYesNo(p,aux.Stringid(25209168,1)) then  --"是否从对方墓地选怪兽特殊召唤？"
		-- 弹出“请选择要特殊召唤的卡”的选择提示，准备让 p 选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		tg1=sg1:Select(p,1,ct1,nil)
		-- 为 p 选中的特殊召唤怪兽显示选中动画，并记录为对象。
		Duel.HintSelection(tg1)
	end
	-- 若对方玩家 1-p 有可用区域且当前回合玩家墓地有可选怪兽，则询问对方是否从当前回合玩家墓地选怪兽特殊召唤。
	if ft2>0 and sg2:GetCount()>0 and Duel.SelectYesNo(1-p,aux.Stringid(25209168,1)) then  --"是否从对方墓地选怪兽特殊召唤？"
		-- 弹出“请选择要特殊召唤的卡”的选择提示，准备让对方选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,1-p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		tg2=sg2:Select(1-p,1,ct2,nil)
		-- 为对方选中的特殊召唤怪兽显示选中动画，并记录为对象。
		Duel.HintSelection(tg2)
	end
	if tg1:GetCount()>0 or tg2:GetCount()>0 then
		-- 中断当前效果处理，使之后进行的特殊召唤视为新的同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 遍历当前回合玩家 p 选择要特殊召唤的怪兽集合。
		for sc1 in aux.Next(tg1) do
			-- 将 p 选择的一只怪兽正面表示特殊召唤到 p 的场上（按苏生限制和召唤条件检查）。
			Duel.SpecialSummonStep(sc1,0,p,p,false,false,POS_FACEUP)
		end
		-- 遍历对方玩家选择要特殊召唤的怪兽集合。
		for sc2 in aux.Next(tg2) do
			-- 将对方选择的一只怪兽正面表示特殊召唤到对方场上（按苏生限制和召唤条件检查）。
			Duel.SpecialSummonStep(sc2,0,1-p,1-p,false,false,POS_FACEUP)
		end
		-- 完成所有特殊召唤步骤，统一触发特殊召唤成功的时点。
		Duel.SpecialSummonComplete()
		-- 从自己卡组中筛选可盖放的陷阱卡，作为后续盖放处理的候选。
		local stg=Duel.GetMatchingGroup(c25209168.stfilter,tp,LOCATION_DECK,0,nil)
		-- 检查自己墓地存在「现世与冥界的逆转」且卡组有可盖放的陷阱卡，才满足后续盖放条件。
		if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,17484499) and stg:GetCount()>0
			-- 满足条件时，询问自己是否从卡组选1张陷阱卡盖放。
			and Duel.SelectYesNo(tp,aux.Stringid(25209168,2)) then  --"是否从卡组选陷阱卡盖放？"
			-- 再次中断效果处理，使盖放陷阱卡与前面的特殊召唤分时点处理。
			Duel.BreakEffect()
			-- 弹出“请选择要盖放的卡”的选择提示，准备让自己选择要盖放的陷阱卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local tc=stg:Select(tp,1,1,nil):GetFirst()
			-- 若选择了陷阱卡且成功盖放到自己场上，则为该陷阱卡赋予『盖放的回合也能发动』的效果。
			if tc and Duel.SSet(tp,tc)~=0 then
				-- 这个效果盖放的卡在盖放的回合也能发动。
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
-- 定义过滤器：判定一张卡在墓地、属于指定玩家且是怪兽，用于统计被这个效果送去对方墓地的怪兽数量。
function c25209168.ctfilter(c,p)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(p) and c:IsType(TYPE_MONSTER)
end
-- 定义过滤器：筛选卡组中类型为陷阱且可以盖放的卡。
function c25209168.stfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
