--メテオ・レイン
-- 效果：
-- 这个回合自己怪兽攻击守备表示的怪兽时，若攻击力超过那个守备力，给与对方那个数值的战斗伤害。
function c64274292.initial_effect(c)
	-- 这个回合自己怪兽攻击守备表示的怪兽时，若攻击力超过那个守备力，给与对方那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c64274292.condition)
	e1:SetOperation(c64274292.activate)
	c:RegisterEffect(e1)
end
-- 定义卡片发动的条件函数
function c64274292.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 定义卡片发动后的效果处理函数
function c64274292.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合自己怪兽攻击守备表示的怪兽时，若攻击力超过那个守备力，给与对方那个数值的战斗伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该贯穿效果注册给玩家，使其在全局环境生效
	Duel.RegisterEffect(e1,tp)
end
