--コトダマ
-- 效果：
-- 只要这张卡在场上表侧表示存在，同名怪兽不能在场上表侧表示存在并破坏。之后召唤·特殊召唤·反转的同名怪兽破坏（同时的场合，同名怪兽全部破坏）。
function c19406822.initial_effect(c)
	-- 卡片效果原文：只要这张卡在场上表侧表示存在，同名怪兽不能在场上表侧表示存在并破坏。之后召唤·特殊召唤·反转的同名怪兽破坏（同时的场合，同名怪兽全部破坏）。
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
-- 检索满足条件的同名怪兽组，用于判断是否需要破坏
function c19406822.filter(c,g,pg)
	if pg:IsContains(c) then return false end
	local code=c:GetCode()
	return g:IsExists(Card.IsCode,1,c,code) or pg:IsExists(Card.IsCode,1,c,code)
end
-- 效果作用：在每次调整阶段检查场上同名怪兽并进行破坏处理
function c19406822.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local phase=Duel.GetCurrentPhase()
	-- 若当前处于伤害步骤但尚未计算战斗伤害，或为伤害计算时则跳过处理
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local c=e:GetHandler()
	local pg=e:GetLabelObject()
	if c:GetFlagEffect(19406822)==0 then
		c:RegisterFlagEffect(19406822,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,1)
		pg:Clear()
	end
	-- 获取场上所有表侧表示的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	local dg=g:Filter(c19406822.filter,nil,g,e:GetLabelObject())
	-- 若没有需要破坏的怪兽或破坏失败则更新记录组
	if dg:GetCount()==0 or Duel.Destroy(dg,REASON_EFFECT)==0 then
		pg:Clear()
		pg:Merge(g)
		pg:Sub(dg)
	else
		-- 重新获取场上所有表侧表示的怪兽组
		g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,nil)
		pg:Clear()
		pg:Merge(g)
		pg:Sub(dg)
		-- 刷新场上卡牌信息，确保状态同步
		Duel.Readjust()
	end
end
