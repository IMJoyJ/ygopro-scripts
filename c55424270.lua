--魔導獣 ケルベロス
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：这张卡的攻击力上升这张卡的魔力指示物数量×500。
-- ③：这张卡进行战斗的战斗阶段结束时这张卡的魔力指示物全部取除。
function c55424270.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 注册连锁发生时的标记效果，用于记录魔法卡发动时该卡已在场上。
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c55424270.acop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升这张卡的魔力指示物数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c55424270.attackup)
	c:RegisterEffect(e2)
	-- ③：这张卡进行战斗的战斗阶段结束时这张卡的魔力指示物全部取除。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c55424270.condition)
	e3:SetOperation(c55424270.operation)
	c:RegisterEffect(e3)
end
-- 在连锁处理结束时，若发动的卡是魔法卡且该卡在发动时已在场，则给该卡放置1个魔力指示物。
function c55424270.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 计算并返回这张卡上的魔力指示物数量×500的数值，作为攻击力上升值。
function c55424270.attackup(e,c)
	return c:GetCounter(0x1)*500
end
-- 确认这张卡在当前回合进行过战斗，作为战斗阶段结束时效果发动的条件。
function c55424270.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 在战斗阶段结束时，将这张卡上的所有魔力指示物全部取除。
function c55424270.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local n=c:GetCounter(0x1)
	if n~=0 then c:RemoveCounter(tp,0x1,n,REASON_EFFECT) end
end
