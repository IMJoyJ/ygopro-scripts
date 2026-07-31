--ダーク・ヴァルキリア
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以当成通常召唤使用的再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●只要这张卡表侧表示存在，只有1次可以给这张卡放置1个魔力指示物。这张卡放置的魔力指示物每有1个，这张卡的攻击力上升300。可以把那1个魔力指示物取除，场上1只怪兽破坏。
function c83269557.initial_effect(c)
	-- 允许此卡在再度召唤（二重状态）且在怪兽区域时放置魔力指示物
	c:EnableCounterPermit(0x1,LOCATION_MZONE,aux.IsDualState)
	-- 注册二重怪兽通用属性（在场上·墓地当作通常怪兽，再度召唤成为效果怪兽）
	aux.EnableDualAttribute(c)
	-- ●这张卡放置的魔力指示物每有1个，这张卡的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 效果生效条件：此卡处于再度召唤（二重状态）
	e2:SetCondition(aux.IsDualState)
	e2:SetValue(c83269557.atkval)
	c:RegisterEffect(e2)
	-- ●只要这张卡表侧表示存在，只有1次可以给这张卡放置1个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(83269557,0))  --"放置魔力指示物"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e3:SetCountLimit(1)
	-- 放置指示物效果发动条件：此卡处于再度召唤（二重状态）
	e3:SetCondition(aux.IsDualState)
	e3:SetTarget(c83269557.target1)
	e3:SetOperation(c83269557.operation1)
	c:RegisterEffect(e3)
	-- ●可以把那1个魔力指示物去除，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(83269557,1))  --"场上一只怪物破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	-- 破坏怪兽效果发动条件：此卡处于再度召唤（二重状态）
	e4:SetCondition(aux.IsDualState)
	e4:SetCost(c83269557.cost2)
	e4:SetTarget(c83269557.target2)
	e4:SetOperation(c83269557.operation2)
	c:RegisterEffect(e4)
end
c83269557.mentioned_counter={
	[0x1]=true,
}
-- 攻击力上升数值计算：返回此卡上的魔力指示物数量×300
function c83269557.atkval(e,c)
	return c:GetCounter(0x1)*300
end
-- 放置魔力指示物效果发动准备：检查是否可放置魔力指示物并设置操作信息
function c83269557.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x1,1) end
	-- 设置连锁操作信息：放置1个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 放置魔力指示物效果处理：给自身放置1个魔力指示物
function c83269557.operation1(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1,1)
end
-- 破坏效果Cost：去除自身1个魔力指示物
function c83269557.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,1,REASON_COST)
end
-- 破坏效果发动准备与目标选择：选择场上1只怪兽作为对象并设置破坏操作信息
function c83269557.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 发动条件检查：场上是否存在可作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：破坏选择的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理：破坏选择的对象怪兽
function c83269557.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的怪兽对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
