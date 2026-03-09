--破滅の女神ルイン
-- 效果：
-- 「世界末日」降临。
-- ①：这张卡的攻击破坏对方怪兽时才能发动。这张卡只再1次可以继续攻击。
function c46427957.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击破坏对方怪兽时才能发动。这张卡只再1次可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46427957,0))  --"连续攻击"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c46427957.atcon)
	e1:SetOperation(c46427957.atop)
	c:RegisterEffect(e1)
end
-- 检测本次战斗是否为该卡攻击并破坏对方怪兽，且该卡是否可以进行连续攻击
function c46427957.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 满足战斗破坏条件且该卡可连续攻击时效果才发动
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
end
-- 使该卡进行1次额外攻击
function c46427957.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行使该卡进行1次额外攻击的操作
	Duel.ChainAttack()
end
