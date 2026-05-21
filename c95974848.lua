--S－Force オリフィス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽不会成为对方的效果的对象。
-- ②：对方场上的怪兽把效果发动时，从手卡把1张「治安战警队」卡除外才能发动。那只怪兽破坏。
function c95974848.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(c95974848.ettg)
	-- 设置不会成为对方（即发动该效果的玩家的对手）的效果的对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：对方场上的怪兽把效果发动时，从手卡把1张「治安战警队」卡除外才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95974848,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,95974848)
	e2:SetCondition(c95974848.descon)
	e2:SetCost(c95974848.descost)
	e2:SetTarget(c95974848.destg)
	e2:SetOperation(c95974848.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：我方场上表侧表示的「治安战警队」怪兽
function c95974848.etfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x156) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 过滤处于同一纵列（正对面）存在我方「治安战警队」怪兽的对方怪兽
function c95974848.ettg(e,c)
	local cg=c:GetColumnGroup()
	return cg:IsExists(c95974848.etfilter,1,nil,e:GetHandlerPlayer())
end
-- 发动条件：对方场上的怪兽把效果发动时
function c95974848.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER) and rp==1-tp
end
-- 过滤手牌中的「治安战警队」卡，或适用替代效果时墓地中的「治安战警队」卡
function c95974848.costfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0x156) and c:IsAbleToRemoveAsCost()
	else
		return e:GetHandler():IsSetCard(0x156) and c:IsHasEffect(55049722,tp) and c:IsAbleToRemoveAsCost()
	end
end
-- 发动代价：从手牌（或适用替代效果时的墓地）将1张「治安战警队」卡除外
function c95974848.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在可作为代价除外的「治安战警队」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c95974848.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张要除外的「治安战警队」卡
	local tg=Duel.SelectMatchingCard(tp,c95974848.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local te=tg:GetFirst():IsHasEffect(55049722,tp)
	if te then
		te:UseCountLimit(tp)
		-- 以替代效果的形式将卡片表侧表示除外
		Duel.Remove(tg,POS_FACEUP,REASON_REPLACE)
	else
		-- 作为代价将卡片表侧表示除外
		Duel.Remove(tg,POS_FACEUP,REASON_COST)
	end
end
-- 效果的目标：设置破坏发动效果怪兽的操作信息
function c95974848.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置破坏操作信息，对象为发动效果的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 效果处理：破坏发动效果的那只怪兽
function c95974848.desop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 将发动效果的怪兽破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
