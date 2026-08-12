--サイバー・バリア・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。这张卡只能通过「攻击反射装置」的效果特殊召唤。这张卡攻击表示的场合，1回合1次，可以把1只对方怪兽的攻击无效。
function c68774379.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。这张卡只能通过「攻击反射装置」的效果特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡攻击表示的场合，1回合1次，可以把1只对方怪兽的攻击无效。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c68774379.discon)
	e2:SetOperation(c68774379.disop)
	c:RegisterEffect(e2)
end
-- 检查自身是否处于表侧攻击表示，且发起攻击的怪兽是否为对方控制的怪兽
function c68774379.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK) and eg:GetFirst():IsControler(1-tp)
end
-- 执行无效攻击的效果处理
function c68774379.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前的攻击
	Duel.NegateAttack()
end
