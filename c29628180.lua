--魔弾－デッドマンズ・バースト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「魔弹」怪兽存在的场合，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c29628180.initial_effect(c)
	-- 创建效果，设置效果类型为发动时无效并破坏，限制发动次数为1次，条件为对方发动魔法或陷阱卡且自己场上有魔弹怪兽，目标为对方发动的卡，效果为无效并破坏对方发动的卡
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,29628180+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c29628180.condition)
	e1:SetTarget(c29628180.target)
	e1:SetOperation(c29628180.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查自己场上的表侧表示的魔弹怪兽
function c29628180.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x108)
end
-- 效果发动条件，检查是否为对方发动魔法或陷阱卡，且该连锁可以被无效，且自己场上有魔弹怪兽
function c29628180.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的魔法或陷阱卡，且该连锁可以被无效
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 检查自己场上有魔弹怪兽
		and Duel.IsExistingMatchingCard(c29628180.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果处理时的操作信息，包括使发动无效和破坏对方发动的卡
function c29628180.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使对方发动的卡无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏对方发动的卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数，使对方发动的卡无效并破坏
function c29628180.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方发动的卡无效，并检查该卡是否与效果有关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对方发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
