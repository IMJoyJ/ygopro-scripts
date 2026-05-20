--王者の看破
-- 效果：
-- ①：自己场上有7星以上的通常怪兽存在的场合，可以把以下效果发动。
-- ●魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ●自己或者对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
function c82382815.initial_effect(c)
	-- ①：自己场上有7星以上的通常怪兽存在的场合，可以把以下效果发动。●自己或者对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(c82382815.condition1)
	e1:SetTarget(c82382815.target1)
	e1:SetOperation(c82382815.activate1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
	-- ①：自己场上有7星以上的通常怪兽存在的场合，可以把以下效果发动。●魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(c82382815.condition2)
	e4:SetTarget(c82382815.target2)
	e4:SetOperation(c82382815.activate2)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上表侧表示的7星以上的通常怪兽
function c82382815.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsType(TYPE_NORMAL)
end
-- 召唤·反转召唤·特殊召唤无效效果的发动条件
function c82382815.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前没有正在处理的连锁，且自己场上存在7星以上的通常怪兽
	return aux.NegateSummonCondition() and Duel.IsExistingMatchingCard(c82382815.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 召唤·反转召唤·特殊召唤无效效果的靶向与操作信息设置
function c82382815.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效怪兽的召唤
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：破坏这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 召唤·反转召唤·特殊召唤无效效果的处理
function c82382815.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在进行的召唤、反转召唤或特殊召唤无效
	Duel.NegateSummon(eg)
	-- 破坏这些召唤被无效的怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 魔法·陷阱卡发动无效效果的发动条件
function c82382815.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动的卡是否为魔法·陷阱卡，且该发动是否可以被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 且自己场上存在7星以上的通常怪兽
		and Duel.IsExistingMatchingCard(c82382815.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 魔法·陷阱卡发动无效效果的靶向与操作信息设置
function c82382815.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使魔法·陷阱卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该魔法·陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 魔法·陷阱卡发动无效效果的处理
function c82382815.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且该卡与效果有关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该魔法·陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
