--八式対魔法多重結界
-- 效果：
-- 从下列效果中选择1项发动：
-- ●使1张以场上1只怪兽为对象的魔法卡的发动与效果无效，并且把它破坏。
-- ●从手卡把1张魔法卡送去墓地。使1张魔法卡的发动与效果无效，并且把它破坏。
function c38275183.initial_effect(c)
	-- 效果原文：●使1张以场上1只怪兽为对象的魔法卡的发动与效果无效，并且把它破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38275183,0))  --"直接无效取1只怪兽为对象的魔法卡"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c38275183.condition1)
	e1:SetTarget(c38275183.target)
	e1:SetOperation(c38275183.activate)
	c:RegisterEffect(e1)
	-- 效果原文：●从手卡把1张魔法卡送去墓地。使1张魔法卡的发动与效果无效，并且把它破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38275183,1))  --"把手卡送去墓地无效魔法卡"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c38275183.condition2)
	e2:SetCost(c38275183.cost)
	e2:SetTarget(c38275183.target)
	e2:SetOperation(c38275183.activate)
	c:RegisterEffect(e2)
end
-- 检查连锁效果是否为取对象效果且对象为1只怪兽
function c38275183.condition1(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁效果的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:GetCount()==1 and tg:GetFirst():IsLocation(LOCATION_MZONE)
		-- 检查连锁效果是否为魔法卡且为永续魔法或反击陷阱且可被无效
		and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 检查连锁效果是否为魔法卡且为永续魔法或反击陷阱且可被无效
function c38275183.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查连锁效果是否为魔法卡且为永续魔法或反击陷阱且可被无效
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 过滤函数：检查手卡中是否存在魔法卡且可作为代价送入墓地
function c38275183.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 设置发动代价：丢弃1张手卡中的魔法卡
function c38275183.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动代价条件：手卡中是否存在至少1张魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c38275183.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手卡操作：丢弃1张手卡中的魔法卡作为代价
	Duel.DiscardHand(tp,c38275183.cfilter,1,1,REASON_COST,nil)
end
-- 设置效果处理时的操作信息：使发动无效并可能破坏对象卡
function c38275183.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏对象卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理：使连锁发动无效并破坏对象卡
function c38275183.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁发动无效且对象卡存在并关联到该效果
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对象卡：以效果原因破坏对象卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
