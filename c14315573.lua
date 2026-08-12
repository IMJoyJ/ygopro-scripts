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
-- 效果条件函数，判断是否满足发动条件
function c14315573.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽是否为对方控制者
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果目标函数，设置效果对象
function c14315573.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设置为效果对象
	Duel.SetTargetCard(tg)
end
-- 效果发动函数，执行效果处理
function c14315573.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽
	local tc=Duel.GetAttacker()
	-- 判断攻击怪兽是否与效果相关且成功无效攻击
	if tc:IsRelateToEffect(e) and Duel.NegateAttack() then
		-- 中断当前效果处理，防止错时点
		Duel.BreakEffect()
		-- 跳过对方的战斗阶段结束步骤
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
