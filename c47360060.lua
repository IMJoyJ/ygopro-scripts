--反射の聖刻印
-- 效果：
-- 把自己场上1只名字带有「圣刻」的怪兽解放才能发动。效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。
function c47360060.initial_effect(c)
	-- 创建效果，设置为发动时无效并破坏对方怪兽、魔法或陷阱卡的效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c47360060.condition)
	e1:SetCost(c47360060.cost)
	e1:SetTarget(c47360060.target)
	e1:SetOperation(c47360060.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判断
function c47360060.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 连锁是否可以被无效，并且发动的是怪兽效果或魔法/陷阱卡的发动
	return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 筛选场上名字带有「圣刻」且未战斗破坏的怪兽
function c47360060.cfilter(c)
	return c:IsSetCard(0x69) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 支付解放1只名字带有「圣刻」的怪兽作为代价
function c47360060.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c47360060.cfilter,1,nil) end
	-- 选择1只满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c47360060.cfilter,1,1,nil)
	-- 将选中的怪兽以代价形式解放
	Duel.Release(g,REASON_COST)
end
-- 设置效果处理时的操作信息，包括无效和破坏
function c47360060.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁发动无效的效果信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁发动破坏的效果信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果，使对方发动无效并破坏对应卡
function c47360060.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁发动无效且该卡仍存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动的卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
