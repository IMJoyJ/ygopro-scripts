--コトダマ
-- 效果：
-- 只要这张卡在场上表侧表示存在，同名怪兽不能在场上表侧表示存在并破坏。之后召唤·特殊召唤·反转的同名怪兽破坏（同时的场合，同名怪兽全部破坏）。
function c19406822.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，同名怪兽不能在场上表侧表示存在并破坏。之后召唤·特殊召唤·反转的同名怪兽破坏（同时的场合，同名怪兽全部破坏）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c19406822.adjustop)
	c:RegisterEffect(e1)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e1:SetLabelObject(g)
end
-- 筛选函数：排除已经记录过的怪兽，若某表侧怪兽的卡名与当前场上其他表侧怪兽或记录组中的怪兽卡名相同，则视为需要破坏的同名怪兽。
function c19406822.filter(c,g,pg)
	if pg:IsContains(c) then return false end
	local code=c:GetCode()
	return g:IsExists(Card.IsCode,1,c,code) or pg:IsExists(Card.IsCode,1,c,code)
end
-- 调整操作为持续效果的事件处理：在每次adjust时获取场上表侧怪兽，筛选出同名怪兽；若无同名怪兽或破坏未成功则仅更新记录，若破坏成功则重新获取场上表侧怪兽更新记录并调用Duel.Readjust()使系统重新调整，以连锁处理后续出现的同名怪兽，同时避免在伤害步骤未计算和伤害计算时执行。
function c19406822.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local phase=Duel.GetCurrentPhase()
	-- 若当前处于伤害阶段且尚未进行伤害计算，或正处于伤害计算阶段，则跳过本次调整，防止在战斗伤害计算的敏感时点干扰战斗。
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local c=e:GetHandler()
	local pg=e:GetLabelObject()
	if c:GetFlagEffect(19406822)==0 then
		c:RegisterFlagEffect(19406822,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,1)
		pg:Clear()
	end
	-- 获取双方场上所有表侧表示怪兽，作为检查同名怪兽的候选集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	local dg=g:Filter(c19406822.filter,nil,g,e:GetLabelObject())
	-- 若筛选出的同名怪兽集合为空，或实际破坏数为0（如因效果抗性未被破坏），则只更新记录；否则进入破坏成功后的分支。
	if dg:GetCount()==0 or Duel.Destroy(dg,REASON_EFFECT)==0 then
		pg:Clear()
		pg:Merge(g)
		pg:Sub(dg)
	else
		-- 在破坏发生后重新获取双方场上剩余的表侧表示怪兽，以便更新记录组。
		g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,nil)
		pg:Clear()
		pg:Merge(g)
		pg:Sub(dg)
		-- 调用Duel.Readjust()刷新场上卡片信息并触发下一次adjust，使因破坏或新召唤而新出现的同名怪兽也能被继续处理。
		Duel.Readjust()
	end
end
