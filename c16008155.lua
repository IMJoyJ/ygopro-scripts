--レプティレス・サーヴァント
-- 效果：
-- 场上有这张卡以外的怪兽表侧表示存在的场合，这张卡破坏。这张卡成为魔法·陷阱卡的效果的对象时，这张卡破坏。只要这张卡在场上表侧表示存在，双方不能把怪兽召唤。
function c16008155.initial_effect(c)
	-- 场上有这张卡以外的怪兽表侧表示存在的场合，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c16008155.sdcon)
	c:RegisterEffect(e1)
	-- 这张卡成为魔法·陷阱卡的效果的对象时，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetOperation(c16008155.desop1)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，双方不能把怪兽召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetOperation(c16008155.desop2)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 效果作用
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_BATTLED)
	e4:SetOperation(c16008155.desop3)
	e4:SetLabelObject(e2)
	c:RegisterEffect(e4)
	-- 效果原文内容
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_SUMMON)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,1)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 检查是否满足破坏条件：存在其他表侧表示的怪兽或自己以外的怪兽
function c16008155.sdcon(e)
	return e:GetHandler():GetOwnerTargetCount()>0
		-- 检查对方场上是否存在至少1张表侧表示的怪兽
		or Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
-- 当成为魔法·陷阱卡效果的对象时，记录该效果并设置标签为0
function c16008155.desop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:GetHandler():IsType(TYPE_SPELL+TYPE_TRAP) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then
		e:SetLabelObject(re)
		e:SetLabel(0)
	end
end
-- 连锁处理结束后，若处于伤害步骤且未计算伤害，则标记为1；否则直接破坏卡片
function c16008155.desop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re==e:GetLabelObject():GetLabelObject() and c:IsRelateToEffect(re) then
		-- 判断当前是否处于伤害步骤且尚未计算伤害
		if Duel.GetCurrentPhase()==PHASE_DAMAGE and not Duel.IsDamageCalculated() then
			e:GetLabelObject():SetLabel(1)
		else
			-- 若卡片未被无效，则将其破坏
			if not c:IsDisabled() then Duel.Destroy(c,REASON_EFFECT) end
		end
	end
end
-- 战斗结束后，若之前标记为1，则破坏该卡片
function c16008155.desop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local des=e:GetLabelObject():GetLabel()
	e:GetLabelObject():SetLabel(0)
	if des==1 and not c:IsDisabled() then
		-- 将卡片以效果原因破坏
		Duel.Destroy(c,REASON_EFFECT)
	end
end
