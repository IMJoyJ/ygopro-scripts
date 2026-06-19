--ヂェミナイ・デビル
-- 效果：
-- 包含把自己手卡丢弃的效果的卡由对方发动时，可以通过把这张卡从手卡送去墓地来让那个发动和效果无效，那张卡破坏然后从自己卡组抽1张卡。
function c67688478.initial_effect(c)
	-- 包含把自己手卡丢弃的效果的卡由对方发动时，可以通过把这张卡从手卡送去墓地来让那个发动和效果无效，那张卡破坏然后从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67688478,0))  --"效果无效并抽卡"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c67688478.condition)
	e1:SetCost(c67688478.cost)
	e1:SetTarget(c67688478.target)
	e1:SetOperation(c67688478.operation)
	c:RegisterEffect(e1)
end
-- 检查触发效果的玩家是否为对方，且该效果是否为魔陷的发动或怪兽效果的发动
function c67688478.condition(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or (not re:IsHasType(EFFECT_TYPE_ACTIVATE) and not re:IsActiveType(TYPE_MONSTER))
		-- 检查该连锁的发动是否可以被无效
		or (not Duel.IsChainNegatable(ev)) then return false end
	local ex,tg,tc,p=Duel.GetOperationInfo(ev,CATEGORY_HANDES_OPPO)
	return re:IsHasCategory(CATEGORY_HANDES_OPPO) or ex
end
-- 检查并执行将此卡从手卡送去墓地的发动代价
function c67688478.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将手卡中的这张卡送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置无效、破坏和抽卡的操作信息
function c67688478.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		-- 设置操作信息：自身玩家抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 执行无效、破坏以及抽卡的效果处理
function c67688478.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的发动无效，若成功且该卡存在则将其破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 中断当前效果处理，使后续的抽卡与破坏不同时处理
		Duel.BreakEffect()
		-- 自身玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
