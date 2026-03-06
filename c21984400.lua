--獣・魔・導
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以把自己场上的魔力指示物的以下数量取除，那个效果发动。
-- ●2个：选自己场上1只「魔导兽」灵摆怪兽回到持有者手卡。
-- ●4个：从自己的额外卡组把1只表侧表示的「魔导兽」灵摆怪兽特殊召唤。那之后，可以给那只怪兽放置2个魔力指示物。
-- ●6个：从自己的额外卡组把1只表侧表示的灵摆怪兽特殊召唤。
function c21984400.initial_effect(c)
	-- 效果原文：①：可以把自己场上的魔力指示物的以下数量取除，那个效果发动。
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
-- 规则层面：检查是否能移除指定数量的魔力指示物作为发动代价
function c21984400.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	-- 规则层面：检查是否能移除指定数量的魔力指示物作为发动代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,ct,REASON_COST) end
	-- 规则层面：向对手提示本卡发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 规则层面：移除指定数量的魔力指示物作为发动代价
	Duel.RemoveCounter(tp,1,0,0x1,ct,REASON_COST)
end
-- 规则层面：定义返回手牌效果的过滤条件
function c21984400.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10d) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 规则层面：设置发动效果时的处理信息
function c21984400.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21984400.thfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 规则层面：设置发动效果时的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
end
-- 规则层面：执行返回手牌效果
function c21984400.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 规则层面：选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c21984400.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面：显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 规则层面：将选中的怪兽送回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 规则层面：定义特殊召唤效果的过滤条件
function c21984400.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10d) and c:IsType(TYPE_PENDULUM)
		-- 规则层面：检查额外卡组的怪兽是否可以特殊召唤
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 规则层面：设置发动效果时的处理信息
function c21984400.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查额外卡组是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21984400.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 规则层面：设置发动效果时的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 规则层面：执行特殊召唤效果
function c21984400.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：选择满足条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,c21984400.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	-- 规则层面：执行特殊召唤操作
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 规则层面：询问是否放置魔力指示物
		if tc:IsCanAddCounter(0x1,2) and Duel.SelectYesNo(tp,aux.Stringid(21984400,3)) then  --"是否放置魔力指示物？"
			tc:AddCounter(0x1,2)
		end
	end
end
-- 规则层面：定义特殊召唤效果的过滤条件
function c21984400.spfilter2(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
		-- 规则层面：检查额外卡组的怪兽是否可以特殊召唤
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 规则层面：设置发动效果时的处理信息
function c21984400.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查额外卡组是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21984400.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 规则层面：设置发动效果时的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 规则层面：执行特殊召唤效果
function c21984400.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：选择满足条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,c21984400.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 规则层面：执行特殊召唤操作
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
