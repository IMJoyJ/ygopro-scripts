--獣・魔・導
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以把自己场上的魔力指示物的以下数量取除，那个效果发动。
-- ●2个：选自己场上1只「魔导兽」灵摆怪兽回到持有者手卡。
-- ●4个：从自己的额外卡组把1只表侧表示的「魔导兽」灵摆怪兽特殊召唤。那之后，可以给那只怪兽放置2个魔力指示物。
-- ●6个：从自己的额外卡组把1只表侧表示的灵摆怪兽特殊召唤。
function c21984400.initial_effect(c)
	-- ①：可以把自己场上的魔力指示物的以下数量取除，那个效果发动。
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
-- 检查是否能移除指定数量的魔力指示物作为发动代价
function c21984400.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	-- 判断是否满足移除指定数量魔力指示物的条件
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,ct,REASON_COST) end
	-- 向对手提示当前发动的效果描述
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 从场上移除指定数量的魔力指示物作为发动代价
	Duel.RemoveCounter(tp,1,0,0x1,ct,REASON_COST)
end
-- 定义返回手牌效果的过滤条件，即场上的「魔导兽」灵摆怪兽
function c21984400.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10d) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 设置发动效果时的目标信息为场上的灵摆怪兽
function c21984400.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21984400.thfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置连锁操作信息，表示将要进行回手牌处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
end
-- 定义发动效果时的具体处理流程，包括选择目标和执行回手牌
function c21984400.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从场上选择满足条件的灵摆怪兽作为目标
	local g=Duel.SelectMatchingCard(tp,c21984400.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 显示所选目标被选为对象的动画效果
		Duel.HintSelection(g)
		-- 将选定的怪兽送回持有者手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 定义特殊召唤效果的过滤条件，即额外卡组中的「魔导兽」灵摆怪兽
function c21984400.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10d) and c:IsType(TYPE_PENDULUM)
		-- 检查目标怪兽是否可以被特殊召唤且场上是否有足够空间
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置发动效果时的目标信息为额外卡组中的灵摆怪兽
function c21984400.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断额外卡组中是否存在满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21984400.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要进行特殊召唤处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义发动效果时的具体处理流程，包括选择目标、执行特殊召唤并可选择放置魔力指示物
function c21984400.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择满足条件的灵摆怪兽作为目标
	local tc=Duel.SelectMatchingCard(tp,c21984400.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	-- 将选定的怪兽特殊召唤到场上
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 判断是否可以放置魔力指示物并询问玩家是否放置
		if tc:IsCanAddCounter(0x1,2) and Duel.SelectYesNo(tp,aux.Stringid(21984400,3)) then  --"是否放置魔力指示物？"
			tc:AddCounter(0x1,2)
		end
	end
end
-- 定义特殊召唤效果的过滤条件，即额外卡组中的灵摆怪兽（不区分种族）
function c21984400.spfilter2(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
		-- 检查目标怪兽是否可以被特殊召唤且场上是否有足够空间
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置发动效果时的目标信息为额外卡组中的灵摆怪兽
function c21984400.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断额外卡组中是否存在满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21984400.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要进行特殊召唤处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义发动效果时的具体处理流程，包括选择目标和执行特殊召唤
function c21984400.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择满足条件的灵摆怪兽作为目标
	local tc=Duel.SelectMatchingCard(tp,c21984400.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选定的怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
