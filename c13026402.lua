--トラップ処理班 Aチーム
-- 效果：
-- 这个效果可以在对方回合使用。对方发动陷阱时，可以把表侧表示的这张卡作祭品，陷阱的发动无效并且破坏。
function c13026402.initial_effect(c)
	-- 这个效果可以在对方回合使用。对方发动陷阱时，可以把表侧表示的这张卡作祭品，陷阱的发动无效并且破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13026402,0))  --"陷阱无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c13026402.condition)
	e1:SetCost(c13026402.cost)
	e1:SetTarget(c13026402.target)
	e1:SetOperation(c13026402.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判断
function c13026402.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp
		-- 对方发动的是陷阱卡且可以被无效
		and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 支付效果代价时的处理
function c13026402.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 设置效果发动时的目标
function c13026402.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使连锁无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏对方陷阱卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果发动时的具体处理
function c13026402.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁无效并确认对方陷阱卡是否存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对方陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
