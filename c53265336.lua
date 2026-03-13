--ドレミコード・スケール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的「七音服」灵摆怪兽卡种类的以下效果各能适用。
-- ●3种类以上：选自己的灵摆区域1张卡回到持有者手卡，从自己的额外卡组选1只表侧表示的「七音服」灵摆怪兽在自己的灵摆区域放置。
-- ●5种类以上：从手卡把1只「七音服」灵摆怪兽特殊召唤。
-- ●7种类以上：对方场上的表侧表示的卡全部破坏。
function c53265336.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,53265336+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c53265336.target)
	e1:SetOperation(c53265336.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤场上「七音服」灵摆怪兽
function c53265336.cfilter(c)
	return c:IsSetCard(0x162) and c:GetOriginalType()&TYPE_PENDULUM>0 and c:IsFaceup()
end
-- 效果作用：过滤额外卡组「七音服」灵摆怪兽
function c53265336.tpfilter(c)
	return c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsForbidden()
end
-- 效果作用：过滤手卡「七音服」灵摆怪兽
function c53265336.spfilter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x162) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：判断是否满足发动条件
function c53265336.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检索场上「七音服」灵摆怪兽
	local g=Duel.GetMatchingGroup(c53265336.cfilter,tp,LOCATION_ONFIELD,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 效果作用：检查灵摆区是否有卡可返回手牌
	local b1=ct>=3 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,nil)
		-- 效果作用：检查额外卡组是否有「七音服」灵摆怪兽可放置
		and Duel.IsExistingMatchingCard(c53265336.tpfilter,tp,LOCATION_EXTRA,0,1,nil)
		-- 效果作用：检查灵摆区是否还有空位
		and Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>0
	-- 效果作用：检查手卡是否有「七音服」灵摆怪兽可特殊召唤
	local b2=ct>=5 and Duel.IsExistingMatchingCard(c53265336.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 效果作用：检查主要怪兽区是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 效果作用：检查对方场上是否有表侧表示的卡
	local b3=ct>=7 and Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)>0
	if chk==0 then return b1 or b2 or b3 end
end
-- 效果原文内容：①：自己场上的「七音服」灵摆怪兽卡种类的以下效果各能适用。
function c53265336.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检索场上「七音服」灵摆怪兽
	local g=Duel.GetMatchingGroup(c53265336.cfilter,tp,LOCATION_ONFIELD,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 效果作用：检查灵摆区是否有卡可返回手牌
	local b1=ct>=3 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,nil)
		-- 效果作用：检查额外卡组是否有「七音服」灵摆怪兽可放置
		and Duel.IsExistingMatchingCard(c53265336.tpfilter,tp,LOCATION_EXTRA,0,1,nil)
		-- 效果作用：检查灵摆区是否还有空位
		and Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>0
	-- 效果原文内容：●3种类以上：选自己的灵摆区域1张卡回到持有者手卡，从自己的额外卡组选1只表侧表示的「七音服」灵摆怪兽在自己的灵摆区域放置。
	if b1 and Duel.SelectYesNo(tp,aux.Stringid(53265336,0)) then  --"是否从额外卡组把灵摆卡放置？"
		-- 效果作用：提示选择返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 效果作用：选择返回手牌的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,1,nil)
		-- 效果作用：将卡送入手牌
		if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
			-- 效果作用：提示选择要放置到场上的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			-- 效果作用：选择要放置到场上的卡
			local sg=Duel.SelectMatchingCard(tp,c53265336.tpfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			local tc=sg:GetFirst()
			if tc then
				-- 效果作用：将卡放置到灵摆区
				Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		end
	end
	-- 效果作用：检索场上「七音服」灵摆怪兽
	g=Duel.GetMatchingGroup(c53265336.cfilter,tp,LOCATION_ONFIELD,0,nil)
	ct=g:GetClassCount(Card.GetCode)
	-- 效果作用：检查手卡是否有「七音服」灵摆怪兽可特殊召唤
	local b2=ct>=5 and Duel.IsExistingMatchingCard(c53265336.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 效果作用：检查主要怪兽区是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 效果原文内容：●5种类以上：从手卡把1只「七音服」灵摆怪兽特殊召唤。
	if b2 and Duel.SelectYesNo(tp,aux.Stringid(53265336,1)) then  --"是否从手卡特殊召唤？"
		-- 效果作用：中断当前效果处理
		Duel.BreakEffect()
		-- 效果作用：提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 效果作用：选择要特殊召唤的卡
		local g=Duel.SelectMatchingCard(tp,c53265336.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 效果作用：将卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 效果作用：检索场上「七音服」灵摆怪兽
	g=Duel.GetMatchingGroup(c53265336.cfilter,tp,LOCATION_ONFIELD,0,nil)
	ct=g:GetClassCount(Card.GetCode)
	-- 效果作用：检查对方场上是否有表侧表示的卡
	local b3=ct>=7 and Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)>0
	-- 效果原文内容：●7种类以上：对方场上的表侧表示的卡全部破坏。
	if b3 and Duel.SelectYesNo(tp,aux.Stringid(53265336,2)) then  --"是否把对方表侧表示的卡全部破坏？"
		-- 效果作用：中断当前效果处理
		Duel.BreakEffect()
		-- 效果作用：检索对方场上的表侧表示的卡
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
		-- 效果作用：将卡全部破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
