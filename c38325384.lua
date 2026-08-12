--魔導加速
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己卡组上面把2张卡送去墓地，以场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置最多2个魔力指示物。
-- ②：这张卡被对方的效果破坏的场合才能发动。可以放置魔力指示物的1只怪兽从卡组特殊召唤，给那只怪兽放置最多2个魔力指示物。
function c38325384.initial_effect(c)
	-- ①：从自己卡组上面把2张卡送去墓地，以场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置最多2个魔力指示物。这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,38325384+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c38325384.cost)
	e1:SetTarget(c38325384.target)
	e1:SetOperation(c38325384.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方的效果破坏的场合才能发动。可以放置魔力指示物的1只怪兽从卡组特殊召唤，给那只怪兽放置最多2个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c38325384.spcon)
	e2:SetTarget(c38325384.sptg)
	e2:SetOperation(c38325384.spop)
	c:RegisterEffect(e2)
end
c38325384.mentioned_counter={
	[0x1]=true,
}
-- 发动代价函数：确认能否作为Cost从自己卡组上面把2张卡送去墓地，并将2张卡送去墓地
function c38325384.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能把卡组上面2张卡作为Cost送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
	-- 作为Cost，从自己卡组上面把2张卡送去墓地
	Duel.DiscardDeck(tp,2,REASON_COST)
end
-- 取对象过滤函数：筛选表侧表示且可以放置魔力指示物的卡
function c38325384.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- 发动目标函数：确认场上存在可以成为对象的、可放置魔力指示物的卡，选择1张作为对象并设置指示物效果的操作信息
function c38325384.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c38325384.filter(chkc) end
	-- 检查双方场上是否存在可以成为效果对象的、表侧表示且可放置魔力指示物的卡
	if chk==0 then return Duel.IsExistingTarget(c38325384.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向自己发送选卡提示「请选择表侧表示的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让自己选择场上1张表侧表示且可放置魔力指示物的卡作为效果对象
	Duel.SelectTarget(tp,c38325384.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：对1张卡放置魔力指示物（指示物效果）
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 效果处理函数：取得对象卡，若其仍为表侧表示且与效果关联，则询问玩家放置2个还是1个魔力指示物，并实际放置
function c38325384.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 若对象卡可以放置2个魔力指示物，则询问玩家是否放置2个魔力指示物
		if tc:IsCanAddCounter(0x1,2) and Duel.SelectYesNo(tp,aux.Stringid(38325384,0)) then  --"是否放置2个魔力指示物？"
			tc:AddCounter(0x1,2)
		else
			tc:AddCounter(0x1,1)
		end
	end
end
-- 发动条件函数：确认这张卡是因对方的效果被破坏的
function c38325384.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
end
-- 特殊召唤过滤函数：筛选可以放置魔力指示物、能添加魔力指示物且可以被特殊召唤的怪兽
function c38325384.spfilter(c,e,tp)
	-- 筛选条件：该卡可以放置魔力指示物、可以实际添加魔力指示物，且满足特殊召唤条件
	return c:IsCanHaveCounter(0x1) and Duel.IsCanAddCounter(tp,0x1,1,c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标函数：检查自己怪兽区有空位且卡组存在可特殊召唤并可放置魔力指示物的怪兽
function c38325384.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否存在可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组中是否存在可以特殊召唤且可放置魔力指示物的怪兽
		and Duel.IsExistingMatchingCard(c38325384.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从自己卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组选1只可放置魔力指示物的怪兽特殊召唤，然后询问玩家给那只怪兽放置2个还是1个魔力指示物，并实际放置
function c38325384.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向自己发送选卡提示「请选择要特殊召唤的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从卡组选择1只可以放置魔力指示物且可以特殊召唤的怪兽
	local tc=Duel.SelectMatchingCard(tp,c38325384.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	-- 将选出的怪兽以表侧表示特殊召唤到自己场上，并确认特殊召唤成功
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 若那只怪兽可以放置2个魔力指示物，则询问玩家是否放置2个魔力指示物
		if tc:IsCanAddCounter(0x1,2) and Duel.SelectYesNo(tp,aux.Stringid(38325384,0)) then  --"是否放置2个魔力指示物？"
			tc:AddCounter(0x1,2)
		else
			tc:AddCounter(0x1,1)
		end
	end
end
