--ジャンクリボー
-- 效果：
-- ①：给与自己伤害的魔法·陷阱·怪兽的效果由对方发动时，把自己的手卡·场上的这张卡送去墓地才能发动。那个发动无效并破坏。
function c38491199.initial_effect(c)
	-- 效果原文内容：①：给与自己伤害的魔法·陷阱·怪兽的效果由对方发动时，把自己的手卡·场上的这张卡送去墓地才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38491199,0))  --"发动无效并破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(c38491199.negcon)
	e1:SetCost(c38491199.negcost)
	e1:SetTarget(c38491199.negtg)
	e1:SetOperation(c38491199.negop)
	c:RegisterEffect(e1)
end
-- 效果作用：支付代价，将自身送去墓地
function c38491199.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 效果作用：将自身以代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果原文内容：给与自己伤害的魔法·陷阱·怪兽的效果由对方发动时
function c38491199.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断是否为对方发动、自身未因战斗破坏、连锁可无效、且自己受到伤害
	return ep==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and aux.damcon1(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果作用：设置连锁无效和破坏的处理信息
function c38491199.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置连锁无效的处理信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		-- 效果作用：设置连锁破坏的处理信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果作用：执行连锁无效并可能破坏相关卡片
function c38491199.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断连锁是否成功无效且相关卡片存在并可破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：破坏目标卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
