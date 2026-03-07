--魔導加速
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己卡组上面把2张卡送去墓地，以场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置最多2个魔力指示物。
-- ②：这张卡被对方的效果破坏的场合才能发动。可以放置魔力指示物的1只怪兽从卡组特殊召唤，给那只怪兽放置最多2个魔力指示物。
function c38325384.initial_effect(c)
	-- ①：从自己卡组上面把2张卡送去墓地，以场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置最多2个魔力指示物。
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
-- 支付将2张卡从卡组送去墓地的代价
function c38325384.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付将2张卡从卡组送去墓地的代价
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
	-- 执行将2张卡从卡组送去墓地的操作
	Duel.DiscardDeck(tp,2,REASON_COST)
end
-- 过滤函数：选择场上表侧表示且能放置魔力指示物的卡
function c38325384.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- 设置效果目标：选择场上1张可以放置魔力指示物的卡
function c38325384.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c38325384.filter(chkc) end
	-- 检查场上是否存在可以放置魔力指示物的卡
	if chk==0 then return Duel.IsExistingTarget(c38325384.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1张可以放置魔力指示物的卡作为效果对象
	Duel.SelectTarget(tp,c38325384.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：准备放置1个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 效果处理：给目标卡放置魔力指示物
function c38325384.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 询问是否放置2个魔力指示物
		if tc:IsCanAddCounter(0x1,2) and Duel.SelectYesNo(tp,aux.Stringid(38325384,0)) then  --"是否放置2个魔力指示物？"
			tc:AddCounter(0x1,2)
		else
			tc:AddCounter(0x1,1)
		end
	end
end
-- 破坏时的发动条件：确认是被对方效果破坏且之前在自己控制下
function c38325384.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
end
-- 过滤函数：选择可以放置魔力指示物且能特殊召唤的怪兽
function c38325384.spfilter(c,e,tp)
	-- 检查怪兽是否可以放置魔力指示物且能特殊召唤
	return c:IsCanHaveCounter(0x1) and Duel.IsCanAddCounter(tp,0x1,1,c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标：选择卡组中可以特殊召唤的怪兽
function c38325384.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有特殊召唤怪兽的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c38325384.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：特殊召唤怪兽并放置魔力指示物
function c38325384.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择卡组中可以特殊召唤的怪兽
	local tc=Duel.SelectMatchingCard(tp,c38325384.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	-- 执行特殊召唤操作
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 询问是否放置2个魔力指示物
		if tc:IsCanAddCounter(0x1,2) and Duel.SelectYesNo(tp,aux.Stringid(38325384,0)) then  --"是否放置2个魔力指示物？"
			tc:AddCounter(0x1,2)
		else
			tc:AddCounter(0x1,1)
		end
	end
end
