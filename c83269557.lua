--ダーク・ヴァルキリア
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以当成通常召唤使用的再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●只要这张卡表侧表示存在，只有1次可以给这张卡放置1个魔力指示物。这张卡放置的魔力指示物每有1个，这张卡的攻击力上升300。可以把那1个魔力指示物取除，场上1只怪兽破坏。
function c83269557.initial_effect(c)
	-- 允许自身在怪兽区域且处于再度召唤状态时放置魔力指示物
	c:EnableCounterPermit(0x1,LOCATION_MZONE,aux.IsDualState)
	-- 注册二重怪兽的通用属性与再度召唤规则
	aux.EnableDualAttribute(c)
	-- 这张卡放置的魔力指示物每有1个，这张卡的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置效果适用条件为自身处于再度召唤状态
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
	-- 设置效果发动条件为自身处于再度召唤状态
	e3:SetCondition(aux.IsDualState)
	e3:SetTarget(c83269557.target1)
	e3:SetOperation(c83269557.operation1)
	c:RegisterEffect(e3)
	-- 可以把那1个魔力指示物取除，场上1只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(83269557,1))  --"场上一只怪物破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	-- 设置效果发动条件为自身处于再度召唤状态
	e4:SetCondition(aux.IsDualState)
	e4:SetCost(c83269557.cost2)
	e4:SetTarget(c83269557.target2)
	e4:SetOperation(c83269557.operation2)
	c:RegisterEffect(e4)
end
-- 攻击力上升值计算函数，返回自身魔力指示物数量×300的值
function c83269557.atkval(e,c)
	return c:GetCounter(0x1)*300
end
-- 放置魔力指示物效果的发动准备与合法性检测
function c83269557.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x1,1) end
	-- 设置操作信息，表示此效果的处理为放置1个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 放置魔力指示物效果的实际处理，给自身放置1个魔力指示物
function c83269557.operation1(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1,1)
end
-- 破坏效果的代价处理，取除自身1个魔力指示物
function c83269557.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,1,REASON_COST)
end
-- 破坏效果的发动准备与取对象检测
function c83269557.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 发动条件检测：场上是否存在至少1只可以成为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示此效果的处理为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的实际处理，破坏选中的对象怪兽
function c83269557.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
