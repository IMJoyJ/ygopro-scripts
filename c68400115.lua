--裸の王様
-- 效果：
-- 场上的全部装备卡的效果无效。
function c68400115.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 场上的全部装备卡的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e2:SetTarget(c68400115.distarget)
	c:RegisterEffect(e2)
	-- 场上的全部装备卡的效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c68400115.disop)
	c:RegisterEffect(e3)
end
-- 确定效果无效的适用对象为场上除自身以外的装备卡
function c68400115.distarget(e,c)
	return c~=e:GetHandler() and c:IsType(TYPE_EQUIP)
end
-- 在连锁处理时，判断发动效果的卡是否为魔陷区的装备卡（且非自身），若是则将其效果无效
function c68400115.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁的发动位置
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_SZONE and re:IsActiveType(TYPE_EQUIP) and re:GetHandler()~=e:GetHandler() then
		-- 使当前连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
