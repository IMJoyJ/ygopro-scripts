--決闘融合－バトル・フュージョン
-- 效果：
-- 「决斗融合」在1回合只能发动1张。
-- ①：自己场上的融合怪兽和对方怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽的攻击力直到伤害步骤结束时上升进行战斗的对方怪兽的攻击力数值。
function c43225434.initial_effect(c)
	-- 「决斗融合」在1回合只能发动1张。①：自己场上的融合怪兽和对方怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽的攻击力直到伤害步骤结束时上升进行战斗的对方怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,43225434+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c43225434.condition)
	e1:SetOperation(c43225434.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件：当前存在攻击目标，且攻击怪兽为己方融合怪兽，或攻击目标为己方表侧表示的融合怪兽，即满足“自己场上的融合怪兽和对方怪兽进行战斗的攻击宣言”。
function c43225434.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击宣言的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前攻击宣言的攻击对象怪兽（直接攻击时为nil）。
	local at=Duel.GetAttackTarget()
	return at and ((a:IsControler(tp) and a:IsType(TYPE_FUSION))
		or (at:IsControler(tp) and at:IsFaceup() and at:IsType(TYPE_FUSION)))
end
-- 效果处理：将己方融合怪兽记为a、对方战斗怪兽记为at（若攻击者是对方则交换，使己方融合怪兽始终为a）；若双方怪兽仍与本次战斗关联且不是里侧表示，则给己方融合怪兽赋予攻击力上升效果，上升值为对方战斗怪兽的当前攻击力，持续到伤害步骤结束。
function c43225434.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击宣言的攻击怪兽（可能为己方或对方），用于之后判断是否需要交换。
	local a=Duel.GetAttacker()
	-- 获取当前攻击宣言的攻击对象怪兽（可能为己方或对方，直接攻击时为nil）。
	local at=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,at=at,a end
	if not a:IsRelateToBattle() or a:IsFacedown() or not at:IsRelateToBattle() or at:IsFacedown() then return end
	-- 那只自己怪兽的攻击力直到伤害步骤结束时上升进行战斗的对方怪兽的攻击力数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	e1:SetValue(at:GetAttack())
	a:RegisterEffect(e1)
end
