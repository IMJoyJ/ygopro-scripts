--獣・魔・導
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以把自己场上的魔力指示物的以下数量取除，那个效果发动。
-- ●2个：选自己场上1只「魔导兽」灵摆怪兽回到持有者手卡。
-- ●4个：从自己的额外卡组把1只表侧表示的「魔导兽」灵摆怪兽特殊召唤。那之后，可以给那只怪兽放置2个魔力指示物。
-- ●6个：从自己的额外卡组把1只表侧表示的灵摆怪兽特殊召唤。
function c21984400.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以把自己场上的魔力指示物的以下数量取除，那个效果发动。●2个：选自己场上1只「魔导兽」灵摆怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21984400,0))  --"取除2个"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,21984400+EFFECT_COUNT_CODE_OATH)
	e1:SetLabel(2)
	e1:SetCost(c21984400.cost)
	e1:SetTarget(c21984400.thtg)
	e1:SetOperation(c21984400.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(21984400,1))  --"取除4个"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetLabel(4)
	e2:SetTarget(c21984400.sptg1)
	e2:SetOperation(c21984400.spop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(21984400,2))  --"取除6个"
	e3:SetLabel(6)
	e3:SetTarget(c21984400.sptg2)
	e3:SetOperation(c21984400.spop2)
	c:RegisterEffect(e3)
end
c21984400.mentioned_counter={
	[0x1]=true,
}
-- 发动代价：取除自己场上Label数量（2/4/6）个魔力指示物，先检查能否取除，再向对方提示选择的效果并实际取除。
function c21984400.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	-- 检查自己场上是否存在足够数量、能以代价取除的魔力指示物（数量为Label值）。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,ct,REASON_COST) end
	-- 向对方玩家提示「对方选择了：」以及本次选择发动的效果选项（取除2/4/6个）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 作为代价实际取除自己场上Label值个魔力指示物。
	Duel.RemoveCounter(tp,1,0,0x1,ct,REASON_COST)
end
-- 回手过滤函数：自己场上表侧表示的、可以回到手卡的「魔导兽」灵摆怪兽。
function c21984400.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10d) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 回手效果的目标处理：检查场上是否存在可回手的「魔导兽」灵摆怪兽，并设置回手分类的操作信息。
function c21984400.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己怪兽区是否存在至少1只满足条件的「魔导兽」灵摆怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c21984400.thfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息：效果处理时将从自己怪兽区把1张卡回到手卡（发动时尚不确定具体卡）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
end
-- 回手效果的处理：提示并让自己选1只满足条件的怪兽，显示选中动画后将其回到持有者手卡。
function c21984400.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向自己发送选卡提示「请选择要返回手牌的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让自己从自己怪兽区选择1只满足条件的「魔导兽」灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c21984400.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 显示所选卡的选中动画，并记录这些卡被选为对象。
		Duel.HintSelection(g)
		-- 以效果处理把选中的卡送去持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 特殊召唤过滤函数：额外卡组中表侧表示的、可以特殊召唤且有空余格子的「魔导兽」灵摆怪兽。
function c21984400.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10d) and c:IsType(TYPE_PENDULUM)
		-- 并且该卡可以被特殊召唤，且自己场上有能让额外卡组怪兽出场的空余格子。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 取除4个效果的目标处理：检查额外卡组是否存在可特殊召唤的「魔导兽」灵摆怪兽，并设置特殊召唤分类的操作信息。
function c21984400.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在至少1只满足条件的「魔导兽」灵摆怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c21984400.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：效果处理时将从自己额外卡组特殊召唤1只怪兽（发动时尚不确定具体卡）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 取除4个效果的处理：让自己从额外卡组选1只「魔导兽」灵摆怪兽特殊召唤，成功后询问是否为那只怪兽放置2个魔力指示物。
function c21984400.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 向自己发送选卡提示「请选择要特殊召唤的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从自己额外卡组选择1只满足条件的「魔导兽」灵摆怪兽。
	local tc=Duel.SelectMatchingCard(tp,c21984400.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	-- 若选中了卡，则将那只怪兽在自己场上以表侧表示特殊召唤，并确认特殊召唤成功。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 若那只怪兽可以放置2个魔力指示物，则询问玩家「是否放置魔力指示物？」。
		if tc:IsCanAddCounter(0x1,2) and Duel.SelectYesNo(tp,aux.Stringid(21984400,3)) then  --"是否放置魔力指示物？"
			tc:AddCounter(0x1,2)
		end
	end
end
-- 特殊召唤过滤函数：额外卡组中表侧表示的、可以特殊召唤且有空余格子的灵摆怪兽（不限「魔导兽」）。
function c21984400.spfilter2(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
		-- 并且该卡可以被特殊召唤，且自己场上有能让额外卡组怪兽出场的空余格子。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 取除6个效果的目标处理：检查额外卡组是否存在可特殊召唤的灵摆怪兽，并设置特殊召唤分类的操作信息。
function c21984400.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在至少1只满足条件的灵摆怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c21984400.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：效果处理时将从自己额外卡组特殊召唤1只怪兽（发动时尚不确定具体卡）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 取除6个效果的处理：让自己从额外卡组选1只灵摆怪兽并在自己场上表侧表示特殊召唤。
function c21984400.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向自己发送选卡提示「请选择要特殊召唤的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从自己额外卡组选择1只满足条件的灵摆怪兽。
	local tc=Duel.SelectMatchingCard(tp,c21984400.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选中的那只怪兽在自己场上以表侧表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
