--速攻のかかし
-- 效果：
-- ①：对方回合的直接攻击宣言时，把这张卡从手卡丢弃才能发动。那次攻击无效。那之后，战斗阶段结束。
function c18964575.initial_effect(c)
	-- ①：对方回合的直接攻击宣言时，把这张卡从手卡丢弃才能发动。那次攻击无效。那之后，战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18964575,0))  --"攻击无效并结束战斗阶段"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c18964575.condition)
	e1:SetCost(c18964575.cost)
	e1:SetOperation(c18964575.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：仅在对方回合、攻击怪兽为对方控制且为直接攻击（攻击对象为空）时，该效果才满足发动条件。
function c18964575.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	-- 判断攻击怪兽的控制者是否为对方（1-tp），且攻击对象不存在，即确认是直接攻击。
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 发动代价判定与执行：chk==0时检查此卡是否能够丢弃；能够丢弃则从手牌将此卡送去墓地，作为发动代价（丢弃）。
function c18964575.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将作为代价的这张卡从手牌送去墓地，丢弃原因标记为COST+DISCARD。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 效果处理：先尝试无效那次攻击；若无效成功，则中断效果处理，并跳过对方的战斗阶段，使战斗阶段结束。
function c18964575.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断本次攻击是否可以被无效，若无效成功则进入后续处理。
	if Duel.NegateAttack() then
		-- 中断当前效果处理，使后续跳过战斗阶段的操作与之前的无效攻击不再视为同一时点处理，避免造成时点问题。
		Duel.BreakEffect()
		-- 跳过对方玩家的战斗阶段，使其在战斗阶段结束步骤后直接进入结束阶段，实现“战斗阶段结束”的效果。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
