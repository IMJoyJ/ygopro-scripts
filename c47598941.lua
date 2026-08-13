--アモルファージ・ライシス
-- 效果：
-- 「无形噬体溶解」的②的效果1回合只能使用1次。
-- ①：「无形噬体」怪兽以外的场上的怪兽的攻击力·守备力下降场上的「无形噬体」卡数量×100。
-- ②：自己的灵摆区域的卡被破坏的场合才能发动。从卡组选1只「无形噬体」灵摆怪兽在自己的灵摆区域放置。
function c47598941.initial_effect(c)
	-- 无对应效果原文；此为该魔法卡自身的发动效果（允许发动此卡，不执行额外处理）。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(47598941,0))  --"发动但不使用效果"
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e0:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置发动效果在伤害步骤的发动条件：仅当处于伤害步骤且尚未进行伤害计算时才能发动。
	e0:SetCondition(aux.dscon)
	c:RegisterEffect(e0)
	-- 「无形噬体溶解」的②的效果1回合只能使用1次。②：自己的灵摆区域的卡被破坏的场合才能发动。从卡组选1只「无形噬体」灵摆怪兽在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47598941,1))  --"发动并使用②效果"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,47598941)
	e2:SetCondition(c47598941.setcon)
	e2:SetTarget(c47598941.settg)
	e2:SetOperation(c47598941.setop)
	c:RegisterEffect(e2)
	-- ①：「无形噬体」怪兽以外的场上的怪兽的攻击力·守备力下降场上的「无形噬体」卡数量×100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetTarget(c47598941.atktg)
	e3:SetValue(c47598941.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
-- 筛选被破坏的卡：被破坏的卡此前位于灵摆区域，且此前控制者是自己（即自己的灵摆区域的卡被破坏）。
function c47598941.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_PZONE) and c:IsPreviousControler(tp)
end
-- ②效果的发动条件：本次被破坏的卡组中存在至少1张由我方控制的、此前位于我方灵摆区域的卡。
function c47598941.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47598941.cfilter,1,nil,tp)
end
-- 筛选卡组中符合条件的「无形噬体」灵摆怪兽：属于「无形噬体」系列、是灵摆怪兽、且未被禁止使用。
function c47598941.filter(c)
	return c:IsSetCard(0xe0) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- ②效果的发动前检查：只有自己灵摆区域有空位，并且卡组中存在符合条件的「无形噬体」灵摆怪兽时才可发动。
function c47598941.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域两个灵摆刻度格中至少有一个是空位。
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 同时检查卡组中是否存在至少1张满足 c47598941.filter 的「无形噬体」灵摆怪兽。
		and Duel.IsExistingMatchingCard(c47598941.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果处理：在灵摆区域仍有空位的前提下，从卡组选出1张符合条件的「无形噬体」灵摆怪兽，正面放置到自己的灵摆区域。
function c47598941.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认灵摆区域仍存在可用空位，若两个格子都已被占用则本次处理不适用。
	if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	-- 向己方玩家给出“从卡组选择要放置到场上的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让己方玩家从卡组中选出1张满足 filter 条件的卡片，结果存入组对象 g。
	local g=Duel.SelectMatchingCard(tp,c47598941.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡片移动到自己的灵摆区域，以表侧表示放置，并使其效果立即适用。
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- ①效果适用对象判定：场上的怪兽如果不是「无形噬体」怪兽，则受到攻击力·守备力变化影响。
function c47598941.atktg(e,c)
	return not c:IsSetCard(0xe0)
end
-- 筛选场上用于计算数量的「无形噬体」卡：要求表侧表示且属于「无形噬体」字段，无论哪方场地都计算。
function c47598941.vfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe0)
end
-- 计算①效果的数值：我方视角下全场表侧表示「无形噬体」卡的数量 × -100。
function c47598941.atkval(e,c)
	-- 返回全场表侧表示「无形噬体」卡的数量乘以 -100，作为攻击力·守备力的下降值。
	return Duel.GetMatchingGroupCount(c47598941.vfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*-100
end
