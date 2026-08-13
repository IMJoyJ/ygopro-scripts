--王家の呪い
-- 效果：
-- ①：只以场上的魔法·陷阱卡1张为对象并要让那张卡破坏的魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c2926176.initial_effect(c)
	-- ①：只以场上的魔法·陷阱卡1张为对象并要让那张卡破坏的魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c2926176.condition)
	e1:SetTarget(c2926176.target)
	e1:SetOperation(c2926176.operation)
	c:RegisterEffect(e1)
end
-- 判断卡片是否为位于场上的魔法·陷阱卡。
function c2926176.cfilter(c)
	return c:IsOnField() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动条件判定：对方发动的魔法·陷阱卡是以场上1张魔法·陷阱卡为对象，且要让那张卡破坏，并且该发动可被无效时才能发动。
function c2926176.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方发动的效果是否为取对象的魔法·陷阱卡发动，且该发动能否被无效；任一不满足则本卡不能发动。
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not Duel.IsChainNegatable(ev) then return false end
	-- 获取对方发动时连锁的对象卡组（即被取对象的场上的魔法·陷阱卡）。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	-- 获取对方发动效果中关于破坏的操作信息，确认该效果确实包含破坏且对象数量为1。
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc==1 and tg:FilterCount(c2926176.cfilter,nil)==tg:GetCount()
end
-- 发动时合法性检查（chk==0直接通过），并设置将对方发动的卡无效并破坏的操作信息。
function c2926176.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁处理将使对方发动的卡无效（CATEGORY_NEGATE）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：本次连锁处理将破坏对方发动的卡（CATEGORY_DESTROY）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：无效对方发动的魔法·陷阱卡，并破坏那张卡。
function c2926176.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判定无效是否成功，且对方发动的卡仍与效果关联（没有因其他原因离场）时才执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动的魔法·陷阱卡破坏（效果破坏）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
