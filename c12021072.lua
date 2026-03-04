--大胆無敵
-- 效果：
-- ①：每次对方把怪兽召唤·反转召唤·特殊召唤，自己回复300基本分。
-- ②：自己基本分是10000以上的场合，自己怪兽不会被战斗破坏。
function c12021072.initial_effect(c)
	-- ①：每次对方把怪兽召唤·反转召唤·特殊召唤，自己回复300基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：自己基本分是10000以上的场合，自己怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c12021072.reccon)
	e2:SetOperation(c12021072.recop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- 每次对方把怪兽召唤·反转召唤·特殊召唤，自己回复300基本分。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCondition(c12021072.indcon)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 判断目标怪兽是否为对方召唤
function c12021072.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 判断是否有对方召唤成功的怪兽
function c12021072.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c12021072.cfilter,1,nil,1-tp)
end
-- 发动效果，回复300基本分
function c12021072.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片发动动画
	Duel.Hint(HINT_CARD,0,12021072)
	-- 使自己回复300基本分
	Duel.Recover(tp,300,REASON_EFFECT)
end
-- 判断自己基本分是否大于等于10000
function c12021072.indcon(e)
	-- 满足条件时，使己方怪兽不会被战斗破坏
	return Duel.GetLP(e:GetHandlerPlayer())>=10000
end
