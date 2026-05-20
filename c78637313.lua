--闇からの呼び声
-- 效果：
-- 「死者苏生」的效果特殊召唤的怪兽全部送去墓地。只要这张卡在场上存在，「死者苏生」不能使用。
function c78637313.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 「死者苏生」的效果特殊召唤的怪兽全部送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c78637313.adjustop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上存在，「死者苏生」不能使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_SSET)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetTarget(c78637313.target)
	c:RegisterEffect(e3)
	-- 只要这张卡在场上存在，「死者苏生」不能使用。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetTargetRange(0,1)
	e4:SetValue(c78637313.aclimit)
	c:RegisterEffect(e4)
end
-- 过滤由「死者苏生」的效果特殊召唤的怪兽。
function c78637313.filter(c)
	local code,code2=c:GetSpecialSummonInfo(SUMMON_INFO_CODE,SUMMON_INFO_CODE2)
	return c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_MONSTER_REBORN or code==83764718 or code2==83764718
end
-- 调整操作：在非伤害步骤（或伤害计算后）将所有由「死者苏生」特殊召唤的怪兽送去墓地，并刷新场上卡片信息。
function c78637313.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local phase=Duel.GetCurrentPhase()
	-- 如果当前是伤害步骤且未计算伤害，或者是伤害计算时，则不进行处理。
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	-- 获取双方场上所有满足「死者苏生」特殊召唤条件的怪兽。
	local g=Duel.GetMatchingGroup(c78637313.filter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将这些怪兽因效果送去墓地，如果成功送去墓地的数量大于0。
	if Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		-- 刷新场上的卡片信息。
		Duel.Readjust()
	end
end
-- 过滤卡名为「死者苏生」的卡片，用于限制覆盖。
function c78637313.target(e,c)
	return c:IsCode(83764718)
end
-- 过滤效果来源为「死者苏生」的效果，用于限制发动。
function c78637313.aclimit(e,re,tp)
	return re:GetHandler():IsCode(83764718)
end
