--攻撃の無力化
-- 效果：
-- ①：对方怪兽的攻击宣言时，以那1只攻击怪兽为对象才能发动。那次攻击无效。那之后，战斗阶段结束。
function c14315573.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时，以那1只攻击怪兽为对象才能发动。那次攻击无效。那之后，战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c14315573.condition)
	e1:SetTarget(c14315573.target)
	e1:SetOperation(c14315573.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：当前攻击宣言的怪兽必须由对方控制（不属于发动方）。
function c14315573.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击宣言的怪兽，并判定其控制者是否为对方玩家（1-tp），是则条件成立。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果发动时的目标选择与合法性判定：将当前攻击宣言的怪兽作为对象，检查其仍在场上且可成为效果对象，然后将其设置为效果对象。
function c14315573.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击宣言的怪兽作为候选目标。
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将当前攻击宣言的怪兽登记为这张卡效果的对象（取对象）。
	Duel.SetTargetCard(tg)
end
-- 效果处理：若攻击怪兽仍与效果关联，则无效那次攻击；成功后中断连锁，并跳过对方战斗阶段，使战斗阶段结束。
function c14315573.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击宣言的怪兽，用于后续无效攻击和跳阶段处理。
	local tc=Duel.GetAttacker()
	-- 判定攻击怪兽是否仍与效果相关（未离场或失去对象联系），并尝试无效攻击；两者均成功才继续。
	if tc:IsRelateToEffect(e) and Duel.NegateAttack() then
		-- 中断当前效果处理，将后续处理视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 跳过对方玩家的战斗阶段，使战斗阶段结束；该跳过效果在战斗步骤结束时重置。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
