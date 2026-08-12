--自爆スイッチ
-- 效果：
-- 当自己的基本分比对方少7000以上时这张卡才能发动。双方的基本分全都变成0。
function c57585212.initial_effect(c)
	-- 当自己的基本分比对方少7000以上时这张卡才能发动。双方的基本分全都变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c57585212.condition)
	e1:SetOperation(c57585212.activate)
	c:RegisterEffect(e1)
end
-- 定义卡片发动的条件函数，判断是否满足基本分差距要求
function c57585212.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家的基本分是否比对方玩家的基本分少7000以上
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)-7000
end
-- 定义卡片发动后的效果处理函数，将双方的基本分归零
function c57585212.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 将当前玩家（自己）的基本分设置为0
	Duel.SetLP(tp,0)
	-- 将对方玩家的基本分设置为0
	Duel.SetLP(1-tp,0)
end
