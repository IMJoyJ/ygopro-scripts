--王家の呪い
-- 效果：
-- ①：只以场上的魔法·陷阱卡1张为对象并要让那张卡破坏的魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c2926176.initial_effect(c)
	-- 效果发动时，使连锁无效并破坏对象卡片
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c2926176.condition)
	e1:SetTarget(c2926176.target)
	e1:SetOperation(c2926176.operation)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的魔法·陷阱卡
function c2926176.cfilter(c)
	return c:IsOnField() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 判断是否满足效果发动条件
function c2926176.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查连锁是否可被无效、是否为魔法·陷阱卡发动、是否为取对象效果
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not Duel.IsChainNegatable(ev) then return false end
	-- 获取连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	-- 获取连锁的破坏效果信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc==1 and tg:FilterCount(c2926176.cfilter,nil)==tg:GetCount()
end
-- 设置效果处理时的操作信息
function c2926176.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏对象卡片的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理，使连锁无效并破坏对象卡片
function c2926176.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁无效并检查对象卡片是否有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对象卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
