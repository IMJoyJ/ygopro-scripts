--ビッグバンガール
-- 效果：
-- 每次自己的基本分回复，对方受到500分的伤害。
function c64752646.initial_effect(c)
	-- 每次自己的基本分回复，对方受到500分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64752646,0))  --"回复基本分时给与对方伤害"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_RECOVER)
	e1:SetCondition(c64752646.cd)
	e1:SetOperation(c64752646.op)
	c:RegisterEffect(e1)
end
-- 检查回复生命值的玩家是否为自己
function c64752646.cd(e,tp,eg,ep,ev,re,r,rp)
	return tp==ep
end
-- 执行给予对方500点伤害的效果处理
function c64752646.op(e,tp,eg,ep,ev,re,r,rp)
	-- 给予对方玩家500点效果伤害
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
