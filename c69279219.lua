--我が身を盾に
-- 效果：
-- 支付1500基本分发动。对方发动的持有「把场上的怪兽破坏的效果」的卡的发动无效并破坏。
function c69279219.initial_effect(c)
	-- 支付1500基本分发动。对方发动的持有「把场上的怪兽破坏的效果」的卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c69279219.condition)
	e1:SetCost(c69279219.cost)
	e1:SetTarget(c69279219.target)
	e1:SetOperation(c69279219.operation)
	c:RegisterEffect(e1)
end
-- 过滤场上的怪兽卡，用于后续判断破坏效果的对象是否包含场上的怪兽
function c69279219.cfilter(c)
	return c:IsOnField() and c:IsType(TYPE_MONSTER)
end
-- 发动条件：对方发动了包含破坏场上怪兽效果的怪兽效果或魔法·陷阱卡的发动，且该连锁的发动可以被无效
function c69279219.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 如果发动者是自己，或者该连锁的发动不能被无效，则不满足条件
	if tp==ep or not Duel.IsChainNegatable(ev) then return false end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取该连锁中关于破坏效果的操作信息（包括是否包含破坏、破坏的目标卡组、破坏的数量）
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(c69279219.cfilter,nil)-tg:GetCount()>0
end
-- 发动代价：支付1500基本分
function c69279219.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能够支付1500基本分
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	-- 支付1500基本分
	Duel.PayLPCost(tp,1500)
end
-- 发动目标：设置无效发动和破坏的操作信息
function c69279219.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果该卡可以被破坏且仍与效果相关联，则设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使该连锁的发动无效并破坏
function c69279219.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该连锁的发动无效，且该卡仍与效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
