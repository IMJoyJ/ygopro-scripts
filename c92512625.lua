--神の忠告
-- 效果：
-- ①：自己的魔法与陷阱区域盖放的卡只有这张卡的场合，支付3000基本分才能发动。
-- ●怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ●自己或者对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
function c92512625.initial_effect(c)
	-- ①：自己的魔法与陷阱区域盖放的卡只有这张卡的场合，支付3000基本分才能发动。●自己或者对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(c92512625.condition1)
	e1:SetCost(c92512625.cost)
	e1:SetTarget(c92512625.target1)
	e1:SetOperation(c92512625.activate1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
	-- ①：自己的魔法与陷阱区域盖放的卡只有这张卡的场合，支付3000基本分才能发动。●怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(c92512625.condition2)
	e4:SetCost(c92512625.cost)
	e4:SetTarget(c92512625.target2)
	e4:SetOperation(c92512625.activate2)
	c:RegisterEffect(e4)
end
-- 过滤函数：筛选出自己魔法与陷阱区域（不含场地区）盖放的卡
function c92512625.cfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
-- 检查发动条件：这张卡在魔陷区盖放，且自己魔陷区没有其他盖放的卡
function c92512625.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_SZONE) and c:IsFacedown()
		-- 检查自己的魔法与陷阱区域是否存在除这张卡以外的盖放的卡
		and not Duel.IsExistingMatchingCard(c92512625.cfilter,tp,LOCATION_SZONE,0,1,c)
end
-- 召唤无效效果的发动条件判定函数
function c92512625.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否处于非连锁状态下的召唤、反转召唤、特殊召唤之际
	return aux.NegateSummonCondition()
		and c92512625.condition(e,tp,eg,ep,ev,re,r,rp)
end
-- 支付3000基本分的发动代价处理函数
function c92512625.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能够支付3000基本分
	if chk==0 then return Duel.CheckLPCost(tp,3000) end
	-- 扣除玩家3000基本分作为发动代价
	Duel.PayLPCost(tp,3000)
end
-- 召唤无效效果的发动目标判定与操作信息设置函数
function c92512625.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效怪兽的召唤
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：破坏这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 召唤无效效果的实际处理函数
function c92512625.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在进行的召唤、反转召唤、特殊召唤无效
	Duel.NegateSummon(eg)
	-- 破坏那些召唤被无效的怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 效果发动无效效果的发动条件判定函数
function c92512625.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动的效果是否为怪兽的效果、魔法、陷阱卡的发动，且该发动可以被无效
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
		and c92512625.condition(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果发动无效效果的发动目标判定与操作信息设置函数
function c92512625.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该卡片或效果的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡片
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果发动无效效果的实际处理函数
function c92512625.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使该连锁的发动无效，并检查该卡是否仍与该效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动被无效的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
