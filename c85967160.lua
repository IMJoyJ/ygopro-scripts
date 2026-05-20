--アロマージ－ベルガモット
-- 效果：
-- ①：只要自己基本分比对方多并有这张卡在怪兽区域存在，自己的植物族怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ②：1回合1次，自己基本分回复的场合发动。这张卡的攻击力·守备力直到对方回合的结束时上升1000。
function c85967160.initial_effect(c)
	-- ①：只要自己基本分比对方多并有这张卡在怪兽区域存在，自己的植物族怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c85967160.pccon)
	-- 设置贯穿效果的影响对象为我方场上的植物族怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PLANT))
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己基本分回复的场合发动。这张卡的攻击力·守备力直到对方回合的结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_RECOVER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c85967160.adcon)
	e2:SetOperation(c85967160.adop)
	c:RegisterEffect(e2)
end
-- 贯穿效果的启用条件：判断自己基本分是否比对方多
function c85967160.pccon(e)
	local tp=e:GetHandlerPlayer()
	-- 比较双方玩家的当前基本分，若我方基本分高于对方则返回true
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
-- 判断回复生命值的玩家是否为自己
function c85967160.adcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 使这张卡的攻击力和守备力直到对方回合结束时上升1000
function c85967160.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力……直到对方回合的结束时上升1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
