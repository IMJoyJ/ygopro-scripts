--カオス・バースト
-- 效果：
-- ①：对方怪兽的攻击宣言时把自己场上1只怪兽解放，以那1只攻击怪兽为对象才能发动。那只攻击怪兽破坏。那之后，给与对方1000伤害。
function c4923662.initial_effect(c)
	-- 创建效果，设置效果分类为破坏和伤害，设置为取对象效果，类型为发动效果，触发事件为攻击宣言时，条件为对方怪兽攻击宣言时才能发动，消耗为解放场上一只怪兽，目标为攻击怪兽，效果处理为破坏攻击怪兽并给予对方1000伤害。
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
-- 对方怪兽的攻击宣言时把自己场上1只怪兽解放，以那1只攻击怪兽为对象才能发动。
function c4923662.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽的攻击宣言时把自己场上1只怪兽解放，以那1只攻击怪兽为对象才能发动。
	return tp~=Duel.GetTurnPlayer()
end
-- 检查自己场上是否存在可解放的怪兽，若有则选择并解放一只作为代价。
function c4923662.cost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否存在可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 从自己场上选择1张满足条件的怪兽进行解放。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将所选怪兽以代價原因进行解放。
	Duel.Release(g,REASON_COST)
end
-- 设置效果目标为当前攻击怪兽，并设定操作信息为破坏该怪兽。
function c4923662.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前正在攻击的怪兽作为目标。
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将当前攻击怪兽设为连锁处理的对象。
	Duel.SetTargetCard(tg)
	-- 设置操作信息，表示要破坏目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
-- 效果处理函数，若目标怪兽存在且未被取消攻击，则将其破坏，并给予对方1000伤害。
function c4923662.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED)
		-- 确认目标怪兽被效果影响且成功破坏。
		and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 中断当前效果处理流程，使后续效果视为不同时处理。
		Duel.BreakEffect()
		-- 给予对方1000点伤害。
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
