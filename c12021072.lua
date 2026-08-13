--大胆無敵
-- 效果：
-- ①：每次对方把怪兽召唤·反转召唤·特殊召唤，自己回复300基本分。
-- ②：自己基本分是10000以上的场合，自己怪兽不会被战斗破坏。
function c12021072.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次对方把怪兽召唤·反转召唤·特殊召唤，自己回复300基本分。
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
	-- ②：自己基本分是10000以上的场合，自己怪兽不会被战斗破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCondition(c12021072.indcon)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 筛选出由指定玩家（此处为对方）召唤的怪兽，用于判断召唤者是否为对方。
function c12021072.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 判定召唤成功的事件组中是否存在至少1只由对方玩家召唤的怪兽，作为回复基本分的效果触发条件。
function c12021072.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c12021072.cfilter,1,nil,1-tp)
end
-- 效果处理：展示本卡动画提示，并让效果持有者回复300基本分。
function c12021072.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家展示卡号12021072的卡片动画提示（不入连锁的效果处理提示）。
	Duel.Hint(HINT_CARD,0,12021072)
	-- 以效果原因让当前效果持有者回复300基本分。
	Duel.Recover(tp,300,REASON_EFFECT)
end
-- 战斗破坏免疫效果的发动条件：检查效果持有者的基本分是否在10000以上。
function c12021072.indcon(e)
	-- 返回效果持有者当前基本分是否不低于10000，用于决定是否适用战斗破坏免疫。
	return Duel.GetLP(e:GetHandlerPlayer())>=10000
end
