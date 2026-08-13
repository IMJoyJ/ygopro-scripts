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
-- 发动条件判定：此卡未处于战斗破坏确定状态，且连锁由对方发动，对方发动的是陷阱卡的发动，且该连锁可以被无效。
function c13026402.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp
		-- 进一步确认对方连锁发动的效果是陷阱卡的发动，且该连锁可以被无效。
		and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 代价函数：若此卡可作为解放代价，则以解放此卡作为发动代价（否则无法发动）。
function c13026402.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将表侧表示的这张卡解放作为发动代价（因为属于代价，不受其他效果影响）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 目标设定：此效果不取对象；登记将对方发动的那张陷阱卡（连锁中的卡 eg）无效，并在其可被破坏且仍与效果关联时登记破坏。
function c13026402.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记无效操作信息：将连锁中的陷阱卡（eg）设为无效类别操作的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记破坏操作信息：当该陷阱卡可被效果破坏且仍与当前效果关联时，将其设为破坏类别操作的对象。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：先无效对方陷阱的发动；若无效成功且该陷阱卡仍与此效果关联，则将其破坏。
function c13026402.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断无效发动是否成功，且被无效的陷阱卡是否仍与当前效果保持关联（防止破坏离场等不相关卡）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏连锁中的那张陷阱卡（即被无效发动的陷阱）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
