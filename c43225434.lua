--決闘融合－バトル・フュージョン
-- 效果：
-- 「决斗融合」在1回合只能发动1张。
-- ①：自己场上的融合怪兽和对方怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽的攻击力直到伤害步骤结束时上升进行战斗的对方怪兽的攻击力数值。
function c43225434.initial_effect(c)
	-- ①：自己场上的融合怪兽和对方怪兽进行战斗的攻击宣言时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,43225434+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c43225434.condition)
	e1:SetOperation(c43225434.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动条件：攻击怪兽或被攻击怪兽中有一只为融合怪兽且为我方控制
function c43225434.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗的被攻击怪兽
	local at=Duel.GetAttackTarget()
	return at and ((a:IsControler(tp) and a:IsType(TYPE_FUSION))
		or (at:IsControler(tp) and at:IsFaceup() and at:IsType(TYPE_FUSION)))
end
-- 发动效果：将攻击怪兽的攻击力上升至被攻击怪兽的攻击力数值
function c43225434.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗的被攻击怪兽
	local at=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,at=at,a end
	if not a:IsRelateToBattle() or a:IsFacedown() or not at:IsRelateToBattle() or at:IsFacedown() then return end
	-- 将攻击怪兽的攻击力直到伤害步骤结束时上升进行战斗的对方怪兽的攻击力数值
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	e1:SetValue(at:GetAttack())
	a:RegisterEffect(e1)
end
