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
-- 攻击无效并结束战斗阶段
function c18964575.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次攻击的怪兽
	local at=Duel.GetAttacker()
	-- 确认攻击怪兽为对方控制者且未攻击其他怪兽
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 将这张卡从手卡丢弃
function c18964575.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡送入墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 无效此次攻击并结束战斗阶段
function c18964575.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效此次攻击
	if Duel.NegateAttack() then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 跳过对方的战斗阶段结束步骤
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
