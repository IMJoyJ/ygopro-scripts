--極炎舞－「辰斗」
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「炎星」怪兽以及「炎舞」魔法·陷阱卡存在，魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c55538156.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「炎星」怪兽以及「炎舞」魔法·陷阱卡存在，魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,55538156+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c55538156.condition)
	e1:SetTarget(c55538156.target)
	e1:SetOperation(c55538156.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「炎星」怪兽
function c55538156.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x79)
end
-- 过滤条件：自己场上表侧表示的「炎舞」魔法·陷阱卡
function c55538156.cfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动条件：魔法·陷阱卡发动时，且自己场上有表侧表示的「炎星」怪兽以及「炎舞」魔法·陷阱卡存在
function c55538156.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动的是否是魔法·陷阱卡的发动，且该连锁的发动可以被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在至少1张表侧表示的「炎星」怪兽
		and Duel.IsExistingMatchingCard(c55538156.cfilter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否存在至少1张表侧表示的「炎舞」魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c55538156.cfilter2,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果的目标处理：如果被连锁的卡与效果有联系且可以被破坏，则设置破坏的操作信息
function c55538156.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		-- 设置操作信息：破坏该发动被无效的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,re:GetHandler(),1,0,0)
	end
end
-- 效果的处理：使该魔法·陷阱卡的发动无效并破坏
function c55538156.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该发动无效，且该卡与效果有联系
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果破坏该卡
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end
