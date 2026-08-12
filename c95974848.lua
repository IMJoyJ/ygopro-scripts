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
	-- 设置不会成为对方效果的对象的过滤条件（仅限制对方的效果）
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ②：对方场上的怪兽把效果发动时，从手卡把1张「治安战警队」卡除外才能发动。那只怪兽破坏。
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
-- 过滤条件：自己场上表侧表示存在的「治安战警队」怪兽
function c95974848.etfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x156) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 过滤条件：对方怪兽的正对面是否有自己的「治安战警队」怪兽
function c95974848.ettg(e,c)
	local cg=c:GetColumnGroup()
	return cg:IsExists(c95974848.etfilter,1,nil,e:GetHandlerPlayer())
end
-- 发动条件：对方场上的怪兽把效果发动时
function c95974848.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER) and rp==1-tp
end
-- 过滤条件：用于支付发动代价的「治安战警队」卡片
function c95974848.costfilter(c,e,tp)
	if c:IsHasEffect(55049722,tp) then
		return e:GetHandler():IsSetCard(0x156) and c:IsAbleToRemoveAsCost()
	elseif c:IsHasEffect(11642993,tp) then
		return e:GetHandler():IsSetCard(0x156) and not c:IsCode(11642993)
			and c:IsSetCard(0x156) and c:IsAbleToGraveAsCost()
	elseif c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0x156) and c:IsAbleToRemoveAsCost()
	end
end
-- 发动代价：从手卡将1张「治安战警队」卡除外（包含治安战警队相关代替代替代价的过滤判断）
function c95974848.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在可用于支付发动代价的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c95974848.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	-- 获取所有可用于支付发动代价的卡片组
	local cg=Duel.GetMatchingGroup(c95974848.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,nil,e,tp)
	if cg:IsExists(Card.IsHasEffect,1,nil,11642993,tp) then
		-- 提示玩家选择要操作的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	else
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	end
	-- 选择1张要作为代价操作或除外的卡片
	local tg=Duel.SelectMatchingCard(tp,c95974848.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
	local te=tg:GetFirst():IsHasEffect(11642993,tp)
	if te then
		-- 展示代替除外代价的卡片发动的提示
		Duel.Hint(HINT_CARD,0,11642993)
		te:UseCountLimit(tp)
		-- 作为代替代价送去墓地
		Duel.SendtoGrave(tg,REASON_COST+REASON_REPLACE)
	else
		local te2=tg:GetFirst():IsHasEffect(55049722,tp)
		if te2 then
			te2:UseCountLimit(tp)
			-- 作为代替代价以表侧表示除外
			Duel.Remove(tg,POS_FACEUP,REASON_COST+REASON_REPLACE)
		else
			-- 从手卡把1张「治安战警队」卡除外
			Duel.Remove(tg,POS_FACEUP,REASON_COST)
		end
	end
end
-- 效果目标：将发动效果的对方怪兽作为破坏的目标
function c95974848.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置破坏发动效果的怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 效果处理：破坏发动效果的那只怪兽
function c95974848.desop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动效果的那只对方怪兽
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
