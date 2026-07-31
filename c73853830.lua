--クルセイダー・オブ・エンディミオン
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●1回合1次，以场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置1个魔力指示物，这张卡的攻击力直到回合结束时上升600。
function c73853830.initial_effect(c)
	-- 注册二重怪兽属性：在场上·墓地当作通常怪兽，再度召唤后获得效果
	aux.EnableDualAttribute(c)
	-- ●1回合1次，以场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置1个魔力指示物，这张卡的攻击力直到回合结束时上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73853830,0))  --"放置魔力指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	-- 效果发动条件：此卡处于二重召唤后的效果怪兽状态
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c73853830.target)
	e1:SetOperation(c73853830.operation)
	c:RegisterEffect(e1)
end
c73853830.mentioned_counter={
	[0x1]=true,
}
-- 效果发动准备与目标确认：选择场上1张可以放置魔力指示物的卡
function c73853830.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsCanAddCounter(0x1,1) end
	-- 发动条件检查：场上是否存在可以放置魔力指示物的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,0x1,1) end
	-- 提示玩家选择要放置魔力指示物的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
	-- 选择场上1张可以放置魔力指示物的卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,0x1,1)
	-- 设置连锁操作信息：放置1个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 效果处理：给目标卡放置1个魔力指示物，并提升自身600攻击力直到回合结束
function c73853830.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁选中的目标卡
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
