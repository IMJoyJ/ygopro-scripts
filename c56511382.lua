--A・ジェネクス・ボルキャノン
-- 效果：
-- ①：1回合1次，把自己场上1只表侧表示的炎属性「次世代」怪兽送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽破坏，给与对方那个等级×400伤害。
function c56511382.initial_effect(c)
	-- ①：1回合1次，把自己场上1只表侧表示的炎属性「次世代」怪兽送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽破坏，给与对方那个等级×400伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56511382,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c56511382.descost)
	e1:SetTarget(c56511382.destg)
	e1:SetOperation(c56511382.desop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示、炎属性且可以作为代价送去墓地的「次世代」怪兽
function c56511382.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGraveAsCost()
end
-- 发动代价（cost）：把自己场上1只表侧表示的炎属性「次世代」怪兽送去墓地
function c56511382.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能支付发动代价（是否存在满足过滤条件的怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(c56511382.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c56511382.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果的目标（target）：以对方场上1只表侧表示怪兽为对象才能发动
function c56511382.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 判断对方场上是否存在表侧表示的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：给与对方该怪兽等级×400的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,g:GetFirst():GetLevel()*400)
end
-- 过滤条件：处于表侧表示且由对方控制的怪兽
function c56511382.desfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp)
end
-- 效果处理（operation）：那只对方的表侧表示怪兽破坏，给与对方那个等级×400伤害
function c56511382.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象怪兽
	local tc=Duel.GetFirstTarget()
	local lv=tc:GetLevel()
	-- 若对象怪兽仍存在于场上且由对方控制，则将其破坏
	if tc:IsRelateToEffect(e) and c56511382.desfilter(tc,1-tp) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给与对方被破坏怪兽等级×400的伤害
		Duel.Damage(1-tp,lv*400,REASON_EFFECT)
	end
end
