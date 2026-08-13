--カオス・バースト
-- 效果：
-- ①：对方怪兽的攻击宣言时把自己场上1只怪兽解放，以那1只攻击怪兽为对象才能发动。那只攻击怪兽破坏。那之后，给与对方1000伤害。
function c4923662.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时把自己场上1只怪兽解放，以那1只攻击怪兽为对象才能发动。那只攻击怪兽破坏。那之后，给与对方1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c4923662.condition)
	e1:SetCost(c4923662.cost)
	e1:SetTarget(c4923662.target)
	e1:SetOperation(c4923662.activate)
	c:RegisterEffect(e1)
end
-- 效果的发动条件函数：判断当前玩家不是回合玩家，即仅在对方回合满足条件。
function c4923662.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前玩家不是回合玩家的判断结果，用于限定对方回合才能发动。
	return tp~=Duel.GetTurnPlayer()
end
-- 效果的发动代价函数：检查自己场上是否有可解放的怪兽，并选择1只解放作为代价。
function c4923662.cost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 代价检查阶段：确认自己场上存在至少1只可解放的怪兽，否则不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 玩家选择1只自己场上的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将选择的怪兽解放，作为发动效果的代价。
	Duel.Release(g,REASON_COST)
end
-- 效果发动时的对象选择函数：将攻击宣言的怪兽作为对象，并设置破坏的操作信息。
function c4923662.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击宣言的怪兽，作为效果对象候选。
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设置为该效果的对象。
	Duel.SetTargetCard(tg)
	-- 设置操作信息，预告将破坏1只对象怪兽（该攻击怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
-- 效果处理函数：破坏对象怪兽；若破坏成功，再给与对方1000伤害。
function c4923662.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED)
		-- 若对象怪兽仍与效果关联且满足可攻击等条件，则将其破坏，并确认破坏成功。
		and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 中断当前效果的处理，使破坏和伤害分成不同时点处理。
		Duel.BreakEffect()
		-- 给与对方玩家1000点效果伤害。
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
