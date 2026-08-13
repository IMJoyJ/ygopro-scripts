--魔導獣 ケルベロス
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：这张卡的攻击力上升这张卡的魔力指示物数量×500。
-- ③：这张卡进行战斗的战斗阶段结束时这张卡的魔力指示物全部取除。
function c55424270.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- ①：只要这张卡在怪兽区域存在，每次自己或对方把魔法卡发动（注册一个不会被无效的永续效果，在效果发动时记录这张卡在场上存在）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 设置辅助操作：用aux.chainreg记录连锁发生时这张卡在场上存在
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- ①：给这张卡放置1个魔力指示物（连锁处理结束时，若该连锁是魔法卡的发动且连锁发生时这张卡在场，放置1个魔力指示物）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c55424270.acop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升这张卡的魔力指示物数量×500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c55424270.attackup)
	c:RegisterEffect(e2)
	-- ③：这张卡进行战斗的战斗阶段结束时这张卡的魔力指示物全部取除
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c55424270.condition)
	e3:SetOperation(c55424270.operation)
	c:RegisterEffect(e3)
end
c55424270.mentioned_counter={
	[0x1]=true,
}
-- 连锁处理结束时，若该连锁的处理是魔法卡的发动，且连锁发生时这张卡已在怪兽区域存在，给这张卡放置1个魔力指示物
function c55424270.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 计算攻击力上升值：这张卡上的魔力指示物数量×500
function c55424270.attackup(e,c)
	return c:GetCounter(0x1)*500
end
-- 判断这个战斗阶段这张卡是否进行过战斗（进行过战斗才满足取除指示物的条件）
function c55424270.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 这张卡上有魔力指示物时，将其全部作为效果取除
function c55424270.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local n=c:GetCounter(0x1)
	if n~=0 then c:RemoveCounter(tp,0x1,n,REASON_EFFECT) end
end
