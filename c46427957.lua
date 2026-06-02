--破滅の女神ルイン
-- 效果：
-- 「世界末日」降临。
-- ①：这张卡的攻击破坏对方怪兽时才能发动。这张卡只再1次可以继续攻击。
function c46427957.initial_effect(c)
	-- 将「世界末日」（8198712）加入卡片记述的相关卡片列表中
	aux.AddCodeList(c,8198712)
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
-- 攻击破坏怪兽时继续攻击效果的发动条件判断
function c46427957.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否因战斗破坏对方怪兽，且自身能进行追加攻击
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
end
-- 攻击破坏怪兽时继续攻击效果的执行过程
function c46427957.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使此卡可以再进行1次攻击
	Duel.ChainAttack()
end
