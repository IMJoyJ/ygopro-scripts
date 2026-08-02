--クルセイダー・オブ・エンディミオン
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●1回合1次，以场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置1个魔力指示物，这张卡的攻击力直到回合结束时上升600。
function c73853830.initial_effect(c)
	-- 为当前卡添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- ●1回合1次，以场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置1个魔力指示物，这张卡的攻击力直到回合结束时上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73853830,0))  --"放置魔力指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	-- 检查当前卡是否处于二重怪兽的再度召唤状态
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c73853830.target)
	e1:SetOperation(c73853830.operation)
	c:RegisterEffect(e1)
end
c73853830.mentioned_counter={
	[0x1]=true,
}
-- 起动效果的目标函数：检查并选择场上1张可以放置魔力指示物的卡作为对象，并设置放置指示物的操作信息
function c73853830.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsCanAddCounter(0x1,1) end
	-- 检查场上是否存在可以放置魔力指示物的卡作为效果对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,0x1,1) end
	-- 提示玩家选择要放置指示物的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
	-- 玩家选择1张可以放置魔力指示物的卡作为目标卡
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,0x1,1)
	-- 设置给对象卡放置指示物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 起动效果的处理函数：给目标卡放置1个魔力指示物，并使当前卡的攻击力直到回合结束时上升600
function c73853830.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取被选择为目标的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsCanAddCounter(0x1,1) then
		tc:AddCounter(0x1,1)
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		-- 这张卡的攻击力直到回合结束时上升600。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(600)
		c:RegisterEffect(e1)
	end
end
