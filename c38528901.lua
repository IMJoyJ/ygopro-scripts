--氷結界の決起隊
-- 效果：
-- ①：把这张卡解放，以场上1只水属性怪兽为对象才能发动。那只水属性怪兽破坏，从卡组把1只「冰结界」怪兽加入手卡。
function c38528901.initial_effect(c)
	-- 效果原文内容：①：把这张卡解放，以场上1只水属性怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38528901,0))  --"破坏，检索"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c38528901.cost)
	e1:SetTarget(c38528901.target)
	e1:SetOperation(c38528901.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：检查是否可以支付解放作为代价
function c38528901.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 规则层面作用：将自身解放作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 规则层面作用：定义水属性怪兽的过滤条件
function c38528901.desfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 规则层面作用：定义「冰结界」怪兽的过滤条件
function c38528901.sfilter(c)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 规则层面作用：设置效果的发动条件，检查场上是否存在满足条件的目标怪兽和卡组中是否存在满足条件的检索卡
function c38528901.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c38528901.desfilter(chkc) end
	-- 规则层面作用：检查场上是否存在满足条件的水属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c38528901.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
		-- 规则层面作用：检查卡组中是否存在满足条件的「冰结界」怪兽
		and Duel.IsExistingMatchingCard(c38528901.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面作用：选择场上满足条件的水属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c38528901.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 规则层面作用：设置效果操作信息，标记将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 规则层面作用：设置效果操作信息，标记将要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果原文内容：那只水属性怪兽破坏，从卡组把1只「冰结界」怪兽加入手卡。
function c38528901.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 规则层面作用：判断对象卡是否仍然存在于场上且满足破坏条件
	if tc:IsRelateToEffect(e) and c38528901.desfilter(tc) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 规则层面作用：提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 规则层面作用：从卡组中选择1只满足条件的「冰结界」怪兽
		local g=Duel.SelectMatchingCard(tp,c38528901.sfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 规则层面作用：将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 规则层面作用：向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
