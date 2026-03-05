--昇天の剛角笛
-- 效果：
-- ①：对方主要阶段由对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。那之后，对方从卡组抽1张，对方主要阶段结束。
function c1637760.initial_effect(c)
	-- 效果原文内容：①：对方主要阶段由对方把怪兽特殊召唤之际才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetCondition(c1637760.condition)
	e1:SetTarget(c1637760.target)
	e1:SetOperation(c1637760.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断是否满足发动条件，包括无未结算连锁、对方回合、对方特殊召唤且在主要阶段1或2。
function c1637760.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查是否无未结算连锁且对方回合
	return aux.NegateSummonCondition() and Duel.GetTurnPlayer()~=tp and rp==1-tp
		-- 规则层面作用：检查当前阶段是否为对方的主要阶段1或2
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果原文内容：那次特殊召唤无效，那些怪兽破坏。那之后，对方从卡组抽1张，对方主要阶段结束。
function c1637760.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：判断对方是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) end
	-- 规则层面作用：设置连锁操作信息为无效召唤效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 规则层面作用：设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 规则层面作用：执行效果操作，使召唤无效、破坏怪兽、对方抽卡并跳过其主要阶段结束
function c1637760.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：使目标怪兽的特殊召唤无效
	Duel.NegateSummon(eg)
	-- 规则层面作用：以效果原因破坏目标怪兽
	Duel.Destroy(eg,REASON_EFFECT)
	-- 规则层面作用：中断当前效果处理，避免错时点
	Duel.BreakEffect()
	-- 规则层面作用：让对方从卡组抽一张卡
	Duel.Draw(1-tp,1,REASON_EFFECT)
	-- 规则层面作用：再次中断当前效果处理，避免错时点
	Duel.BreakEffect()
	-- 规则层面作用：跳过对方当前主要阶段的结束阶段
	Duel.SkipPhase(1-tp,Duel.GetCurrentPhase(),RESET_PHASE+PHASE_END,1)
end
