--トゥーン・テラー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「卡通世界」以及卡通怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c53094821.initial_effect(c)
	-- 记录该卡与「卡通世界」的关联，用于效果判定
	aux.AddCodeList(c,15259703)
	-- ①：自己场上有「卡通世界」以及卡通怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,53094821+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c53094821.condition)
	e1:SetTarget(c53094821.target)
	e1:SetOperation(c53094821.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查场上是否存在表侧表示的「卡通世界」
function c53094821.cfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤函数：检查场上是否存在表侧表示的卡通怪兽
function c53094821.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 效果发动条件判断：确保发动的是怪兽效果或魔法/陷阱卡，且连锁可无效，并满足场上有「卡通世界」和卡通怪兽的条件
function c53094821.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动的是否为怪兽效果或魔法/陷阱卡，以及该连锁是否可以被无效
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在至少1张表侧表示的「卡通世界」
		and Duel.IsExistingMatchingCard(c53094821.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查自己场上是否存在至少1只表侧表示的卡通怪兽
		and Duel.IsExistingMatchingCard(c53094821.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果处理时的操作信息：将发动无效和可能破坏的卡作为目标
function c53094821.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		-- 设置操作信息为破坏发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数：使连锁发动无效并破坏对应卡
function c53094821.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁无效且发动的卡仍存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动的卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
