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
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c23171610.target)
	e1:SetOperation(c23171610.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否存在正面朝上的机械族怪兽
function c23171610.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 效果发动时的处理函数，检查场上是否存在正面朝上的机械族怪兽
function c23171610.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若场上不存在正面朝上的机械族怪兽则效果不发动
	if chk==0 then return Duel.IsExistingMatchingCard(c23171610.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 过滤函数，用于判断场上是否存在正面朝上且未被该效果免疫的机械族怪兽
function c23171610.filter2(c,e)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and not c:IsImmuneToEffect(e)
end
-- 效果发动时的处理函数，将符合条件的怪兽攻击力变为2倍，并在结束阶段破坏
function c23171610.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有正面朝上且未被该效果免疫的机械族怪兽
	local sg=Duel.GetMatchingGroup(c23171610.filter2,tp,LOCATION_MZONE,0,nil,e)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	local tc=sg:GetFirst()
	while tc do
		-- 将怪兽攻击力变为2倍
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
	-- 在结束阶段时触发的效果，用于破坏符合条件的怪兽
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
	-- 将结束阶段破坏效果注册到全局环境
	Duel.RegisterEffect(e2,tp)
end
-- 过滤函数，用于判断怪兽是否为本次效果所影响的怪兽
function c23171610.desfilter(c,fid)
	return c:GetFlagEffectLabel(23171610)==fid
end
-- 判断是否还有符合条件的怪兽需要被破坏
function c23171610.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c23171610.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 执行破坏操作，将符合条件的怪兽破坏
function c23171610.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local dg=g:Filter(c23171610.desfilter,nil,e:GetLabel())
	g:DeleteGroup()
	-- 将怪兽破坏
	Duel.Destroy(dg,REASON_EFFECT)
end
