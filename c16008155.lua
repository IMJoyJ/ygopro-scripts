--レプティレス・サーヴァント
-- 效果：
-- 场上有这张卡以外的怪兽表侧表示存在的场合，这张卡破坏。这张卡成为魔法·陷阱卡的效果的对象时，这张卡破坏。只要这张卡在场上表侧表示存在，双方不能把怪兽召唤。
function c16008155.initial_effect(c)
	-- 场上有这张卡以外的怪兽表侧表示存在的场合，这张卡破坏。这张卡成为魔法·陷阱卡的效果的对象时，这张卡破坏。
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
	-- 这张卡成为魔法·陷阱卡的效果的对象时，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetOperation(c16008155.desop2)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 这张卡成为魔法·陷阱卡的效果的对象时，这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_BATTLED)
	e4:SetOperation(c16008155.desop3)
	e4:SetLabelObject(e2)
	c:RegisterEffect(e4)
	-- 只要这张卡在场上表侧表示存在，双方不能把怪兽召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_SUMMON)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,1)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 判定自我破坏是否适用：若本卡正被其他卡作为永续对象（持续取对象），或场上存在除本卡以外的表侧表示怪兽，则满足自坏条件，本卡破坏。
function c16008155.sdcon(e)
	return e:GetHandler():GetOwnerTargetCount()>0
		-- 检查场上是否存在除这张卡以外的表侧表示怪兽，存在则满足自坏条件。
		or Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
-- 本卡成为效果对象时，若该效果的发动者是魔法·陷阱卡且本卡在怪兽区表侧表示，则把该效果存入LabelObject，并将Label置0，用于后续连锁结束时判定是否自坏。
function c16008155.desop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:GetHandler():IsType(TYPE_SPELL+TYPE_TRAP) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then
		e:SetLabelObject(re)
		e:SetLabel(0)
	end
end
-- 连锁处理结束时，若当前连锁的效果正是之前记录过的使本卡成为对象的魔法·陷阱效果，且本卡仍与该效果关联，则处理破坏；若在伤害阶段且伤害未计算，则延迟到伤害计算后。
function c16008155.desop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re==e:GetLabelObject():GetLabelObject() and c:IsRelateToEffect(re) then
		-- 判断是否处于伤害阶段且尚未计算伤害；若是则暂不破坏，待伤害计算后再执行。
		if Duel.GetCurrentPhase()==PHASE_DAMAGE and not Duel.IsDamageCalculated() then
			e:GetLabelObject():SetLabel(1)
		else
			-- 若本卡效果没有被无效，则以效果破坏本卡。
			if not c:IsDisabled() then Duel.Destroy(c,REASON_EFFECT) end
		end
	end
end
-- 伤害计算后的时点：读取之前延迟的破坏标记（Label），清除标记；若标记为1且本卡未被无效，则将本卡破坏。
function c16008155.desop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local des=e:GetLabelObject():GetLabel()
	e:GetLabelObject():SetLabel(0)
	if des==1 and not c:IsDisabled() then
		-- 以效果原因破坏这张卡（送入墓地）。
		Duel.Destroy(c,REASON_EFFECT)
	end
end
