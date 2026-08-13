--昇天の剛角笛
-- 效果：
-- ①：对方主要阶段由对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。那之后，对方从卡组抽1张，对方主要阶段结束。
function c1637760.initial_effect(c)
	-- 对应效果原文：①：对方主要阶段由对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。那之后，对方从卡组抽1张，对方主要阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetCondition(c1637760.condition)
	e1:SetTarget(c1637760.target)
	e1:SetOperation(c1637760.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判断：仅在无连锁处理中、对方回合、对方怪兽特殊召唤之际且当前为对方主要阶段时才能发动。
function c1637760.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前没有正在处理的连锁（非同一连锁上连续发动），且当前是对方回合（我方不是回合玩家），且特殊召唤的操作方是对方玩家。
	return aux.NegateSummonCondition() and Duel.GetTurnPlayer()~=tp and rp==1-tp
		-- 检查当前阶段是主要阶段1或主要阶段2，满足“对方主要阶段”的发动时机要求。
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果发动目标与操作信息设定：确认合法后，将这次特殊召唤的怪兽组写入操作信息，用于无效召唤和破坏。
function c1637760.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：确认对方玩家可以抽1张卡，这是后续处理能够执行的前提。
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) end
	-- 设置操作信息：将本次特殊召唤的怪兽组登记为「无效召唤」的对象，用于召唤无效类效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：将本次特殊召唤的怪兽组登记为「破坏」的对象，用于破坏效果相关检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 效果处理：先无效那次特殊召唤并破坏那些怪兽，然后让对方抽1张卡，最后跳过对方的当前主要阶段。
function c1637760.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在进行的特殊召唤无效，阻止那些怪兽被特殊召唤。
	Duel.NegateSummon(eg)
	-- 将被无效召唤的怪兽破坏（因特殊召唤被无效，实际破坏的是未能成功召唤的怪兽，按规则送入墓地）。
	Duel.Destroy(eg,REASON_EFFECT)
	-- 中断当前效果链，使之后的抽卡处理视为另一次独立效果处理，避免时点被连带触发。
	Duel.BreakEffect()
	-- 让对手玩家从卡组抽1张卡（作为效果处理的一部分）。
	Duel.Draw(1-tp,1,REASON_EFFECT)
	-- 再次中断效果链，使后续跳过阶段处理与抽卡处理分离，确保各步骤的时点正确。
	Duel.BreakEffect()
	-- 跳过对方当前的（主要）阶段，使对方的主要阶段直接结束，效果结算后进入结束阶段。
	Duel.SkipPhase(1-tp,Duel.GetCurrentPhase(),RESET_PHASE+PHASE_END,1)
end
