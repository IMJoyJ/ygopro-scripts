--ライフチェンジャー
-- 效果：
-- 双方基本分有8000以上的相差的场合才能发动。双方基本分变成3000。
function c17178486.initial_effect(c)
	-- 卡片效果注册，设置为魔法卡发动效果，触发时点为自由时点，条件为双方基本分相差8000以上，发动时执行activate函数
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c17178486.condition)
	e1:SetOperation(c17178486.activate)
	c:RegisterEffect(e1)
end
-- 判断双方基本分是否有8000以上的差距
function c17178486.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家与对手基本分差是否大于等于8000
	return Duel.GetLP(tp)-Duel.GetLP(1-tp)>=8000 or Duel.GetLP(1-tp)-Duel.GetLP(tp)>=8000
end
-- 设置双方基本分都变为3000
function c17178486.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 将当前玩家的基本分设置为3000
	Duel.SetLP(tp,3000)
	-- 将对手玩家的基本分设置为3000
	Duel.SetLP(1-tp,3000)
end
