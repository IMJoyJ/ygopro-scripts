--魔導戦士 ブレイカー
-- 效果：
-- ①：这张卡召唤的场合发动。给这张卡放置1个魔力指示物（最多1个）。
-- ②：这张卡的攻击力上升这张卡的魔力指示物数量×300。
-- ③：把这张卡1个魔力指示物取除，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c71413901.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,1)
	-- ①：这张卡召唤的场合发动。给这张卡放置1个魔力指示物（最多1个）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71413901,0))  --"放置魔力指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c71413901.addct)
	e1:SetOperation(c71413901.addc)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升这张卡的魔力指示物数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c71413901.attackup)
	c:RegisterEffect(e2)
	-- ③：把这张卡1个魔力指示物去除，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(71413901,2))  --"破坏一张魔法陷阱卡"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCost(c71413901.descost)
	e3:SetTarget(c71413901.destg)
	e3:SetOperation(c71413901.desop)
	c:RegisterEffect(e3)
end
c71413901.mentioned_counter={
	[0x1]=true,
}
-- ①效果发动准备与操作信息设置
function c71413901.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：放置1个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- ①效果处理：给此卡放置1个魔力指示物
function c71413901.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 攻击力上升数值计算：此卡的魔力指示物数量×300
function c71413901.attackup(e,c)
	return c:GetCounter(0x1)*300
end
-- ③效果发动Cost：去除此卡1个魔力指示物
function c71413901.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,1,REASON_COST)
end
-- 破坏对象过滤：场上的魔法·陷阱卡
function c71413901.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ③效果发动准备：选择场上1张魔法·陷阱卡为对象并设置破坏操作信息
function c71413901.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c71413901.filter(chkc) end
	-- 发动条件检查：场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c71413901.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,c71413901.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③效果处理：破坏对象卡片
function c71413901.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏对象卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
