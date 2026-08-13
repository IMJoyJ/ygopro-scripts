--ドレミコード・スケール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的「七音服」灵摆怪兽卡种类的以下效果各能适用。
-- ●3种类以上：选自己的灵摆区域1张卡回到持有者手卡，从自己的额外卡组选1只表侧表示的「七音服」灵摆怪兽在自己的灵摆区域放置。
-- ●5种类以上：从手卡把1只「七音服」灵摆怪兽特殊召唤。
-- ●7种类以上：对方场上的表侧表示的卡全部破坏。
function c53265336.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上的「七音服」灵摆怪兽卡种类的以下效果各能适用。●3种类以上：选自己的灵摆区域1张卡回到持有者手卡，从自己的额外卡组选1只表侧表示的「七音服」灵摆怪兽在自己的灵摆区域放置。●5种类以上：从手卡把1只「七音服」灵摆怪兽特殊召唤。●7种类以上：对方场上的表侧表示的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,53265336+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c53265336.target)
	e1:SetOperation(c53265336.operation)
	c:RegisterEffect(e1)
end
-- 筛选自己场上表侧表示且原本种类包含灵摆的「七音服」卡，用于按卡名统计灵摆怪兽的种类数。
function c53265336.cfilter(c)
	return c:IsSetCard(0x162) and c:GetOriginalType()&TYPE_PENDULUM>0 and c:IsFaceup()
end
-- 筛选额外卡组表侧表示、是「七音服」灵摆怪兽且未被禁止的卡，作为可放置到灵摆区的候选。
function c53265336.tpfilter(c)
	return c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsForbidden()
end
-- 筛选手卡中「七音服」灵摆怪兽且能够被效果特殊召唤的卡。
function c53265336.spfilter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x162) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动合法性判定：统计自己场上表侧「七音服」灵摆怪兽的卡名种类数，若满足3/5/7种类对应效果的至少一个可执行条件，则允许发动。
function c53265336.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己场上（怪兽·魔陷区域）表侧表示、原种类为灵摆的「七音服」卡的集合，用于计算种类数。
	local g=Duel.GetMatchingGroup(c53265336.cfilter,tp,LOCATION_ONFIELD,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 判定条件：种类数≥3，且自己灵摆区有卡可以返回手卡。
	local b1=ct>=3 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,nil)
		-- 并且额外卡组有1张以上表侧「七音服」灵摆卡可放置到灵摆区。
		and Duel.IsExistingMatchingCard(c53265336.tpfilter,tp,LOCATION_EXTRA,0,1,nil)
		-- 并且自己灵摆区确实存在卡（确保有可选择的返回对象）。
		and Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>0
	-- 判定条件：种类数≥5，且手卡有可特殊召唤的「七音服」灵摆怪兽。
	local b2=ct>=5 and Duel.IsExistingMatchingCard(c53265336.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 并且自己主要怪兽区有空位可供特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 判定条件：种类数≥7，且对方场上有表侧表示的卡可以破坏。
	local b3=ct>=7 and Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)>0
	if chk==0 then return b1 or b2 or b3 end
end
-- 效果处理：重新统计种类数，按3/5/7种类各阶段让玩家选择是否适用；依次执行灵摆区卡回手并从额外卡组放置、手卡灵摆怪兽特殊召唤、对方表侧卡全部破坏。
function c53265336.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理中再次取得自己场上符合条件的「七音服」灵摆卡集合，重新计算种类数（用于后续分支判定）。
	local g=Duel.GetMatchingGroup(c53265336.cfilter,tp,LOCATION_ONFIELD,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 分支1判定：重新确认是否满足3种类以上且灵摆区有可回手卡、额外有可放置卡。
	local b1=ct>=3 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,nil)
		-- 分支1的额外卡组侧条件：存在可放置到灵摆区的表侧「七音服」灵摆怪兽。
		and Duel.IsExistingMatchingCard(c53265336.tpfilter,tp,LOCATION_EXTRA,0,1,nil)
		-- 分支1的灵摆区侧条件：自己灵摆区有卡存在。
		and Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>0
	-- 若分支1可执行且玩家选择“是”，则开始处理『3种类以上』效果。
	if b1 and Duel.SelectYesNo(tp,aux.Stringid(53265336,0)) then  --"是否从额外卡组把灵摆卡放置？"
		-- 弹出选择提示：从自己灵摆区选择要返回手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 玩家从自己灵摆区选择1张可返回手卡的卡。
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,1,nil)
		-- 将选择的灵摆区卡返回持有者手卡；若返回成功，才继续处理从额外卡组放置。
		if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
			-- 弹出选择提示：从额外卡组选择要放置到灵摆区的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			-- 玩家从额外卡组选择1张表侧表示、符合条件的「七音服」灵摆卡。
			local sg=Duel.SelectMatchingCard(tp,c53265336.tpfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			local tc=sg:GetFirst()
			if tc then
				-- 将选择的额外灵摆卡以表侧表示放置到自己的灵摆区（enable=true 表示放置后立即适用该卡效果）。
				Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		end
	end
	-- 重新获取符合条件的「七音服」灵摆卡集合，为下一个分支重新计算种类数。
	g=Duel.GetMatchingGroup(c53265336.cfilter,tp,LOCATION_ONFIELD,0,nil)
	ct=g:GetClassCount(Card.GetCode)
	-- 分支2判定：重新确认是否满足5种类以上且手卡有可特殊召唤的灵摆怪兽。
	local b2=ct>=5 and Duel.IsExistingMatchingCard(c53265336.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 并且主要怪兽区有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 若分支2可执行且玩家选择“是”，则开始处理『5种类以上』效果。
	if b2 and Duel.SelectYesNo(tp,aux.Stringid(53265336,1)) then  --"是否从手卡特殊召唤？"
		-- 中断当前效果处理，让之后的操作（特殊召唤）作为不同时点处理。
		Duel.BreakEffect()
		-- 弹出选择提示：从手卡选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从手卡选择1只可特殊召唤的「七音服」灵摆怪兽。
		local g=Duel.SelectMatchingCard(tp,c53265336.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 再次重新获取符合条件的「七音服」灵摆卡集合，为最终分支重新计算种类数。
	g=Duel.GetMatchingGroup(c53265336.cfilter,tp,LOCATION_ONFIELD,0,nil)
	ct=g:GetClassCount(Card.GetCode)
	-- 分支3判定：重新确认是否满足7种类以上且对方场上有表侧表示的卡。
	local b3=ct>=7 and Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)>0
	-- 若分支3可执行且玩家选择“是”，则开始处理『7种类以上』效果。
	if b3 and Duel.SelectYesNo(tp,aux.Stringid(53265336,2)) then  --"是否把对方表侧表示的卡全部破坏？"
		-- 再次中断当前效果处理，使破坏效果独立结算并造成新的时点。
		Duel.BreakEffect()
		-- 取得对方场上全部表侧表示的卡（怪兽·魔陷）作为破坏对象。
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
		-- 将对方场上表侧表示的卡全部破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
