--リミッター解除
-- 效果：
-- ①：自己场上的全部机械族怪兽的攻击力直到回合结束时变成2倍。这个回合的结束阶段，这个效果适用中的怪兽破坏。
function c23171610.initial_effect(c)
	-- ①：自己场上的全部机械族怪兽的攻击力直到回合结束时变成2倍。这个回合的结束阶段，这个效果适用中的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件：伤害步骤中仅可在伤害计算前发动（非伤害步骤或无伤害计算时也可发动）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c23171610.target)
	e1:SetOperation(c23171610.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤器：选择自己场上表侧表示且种族为机械族的怪兽。
function c23171610.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 定义效果发动时的Target函数：在发动时确认自己场上是否存在符合条件的机械族怪兽，作为发动前提。
function c23171610.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时的合法性检查：若自己场上没有表侧机械族怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c23171610.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 定义处理时的过滤器：选择自己场上表侧机械族且不免疫该效果的怪兽。
function c23171610.filter2(c,e)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and not c:IsImmuneToEffect(e)
end
-- 效果处理：获取所有适用的机械族怪兽，将其攻击力变为2倍并附加本次效果的标识；随后注册一个结束阶段的持续效果，用于破坏这些怪兽。
function c23171610.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上满足条件的机械族怪兽（表侧、机械族、不免疫此效果）的集合。
	local sg=Duel.GetMatchingGroup(c23171610.filter2,tp,LOCATION_MZONE,0,nil,e)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	local tc=sg:GetFirst()
	while tc do
		-- ①：自己场上的全部机械族怪兽的攻击力直到回合结束时变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetAttack()*2)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(23171610,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		tc=sg:GetNext()
	end
	sg:KeepAlive()
	-- 这个回合的结束阶段，这个效果适用中的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabel(fid)
	e2:SetLabelObject(sg)
	e2:SetCondition(c23171610.descon)
	e2:SetOperation(c23171610.desop)
	-- 将结束阶段破坏怪兽的持续效果e2注册到当前玩家，使其在该回合结束阶段生效。
	Duel.RegisterEffect(e2,tp)
end
-- 定义过滤器：判断怪兽是否带有本次效果赋予的标记（flag标签等于fid），用于确定哪些怪兽曾被攻击力翻倍。
function c23171610.desfilter(c,fid)
	return c:GetFlagEffectLabel(23171610)==fid
end
-- 定义结束阶段效果的发动条件：若保存的怪兽组中已不存在仍带有该标记的怪兽，则清空并重置该效果，不进行破坏；否则允许执行破坏。
function c23171610.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c23171610.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 定义结束阶段的破坏操作：从保存的怪兽组中筛选出仍带有该标记的怪兽，并将其破坏。
function c23171610.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local dg=g:Filter(c23171610.desfilter,nil,e:GetLabel())
	g:DeleteGroup()
	-- 以效果原因破坏筛选出的怪兽，即执行结束阶段对被翻倍攻击力怪兽的破坏。
	Duel.Destroy(dg,REASON_EFFECT)
end
