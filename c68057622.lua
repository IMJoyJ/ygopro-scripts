--カウンターマシンガンパンチ
-- 效果：
-- 若被攻击的守备怪兽的守备力比对方攻击怪兽的攻击力高，则这只攻击怪兽被破坏。
function c68057622.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 若被攻击的守备怪兽的守备力比对方攻击怪兽的攻击力高，则这只攻击怪兽被破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c68057622.descon)
	e2:SetOperation(c68057622.desop)
	c:RegisterEffect(e2)
end
-- 检查是否满足条件：存在攻击目标，且对方的攻击怪兽与我方的守备表示怪兽进行战斗，且攻击怪兽的攻击力低于守备怪兽的守备力
function c68057622.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗被攻击的怪兽
	local at=Duel.GetAttackTarget()
	return at and a:IsControler(1-tp) and a:IsRelateToBattle()
		and at:IsDefensePos() and at:IsRelateToBattle() and a:GetAttack()<at:GetDefense()
end
-- 执行效果，将攻击怪兽破坏
function c68057622.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏本次战斗的攻击怪兽
	Duel.Destroy(Duel.GetAttacker(),REASON_EFFECT)
end
