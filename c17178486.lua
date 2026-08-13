--ライフチェンジャー
-- 效果：
-- 双方基本分有8000以上的相差的场合才能发动。双方基本分变成3000。
function c17178486.initial_effect(c)
	-- 对应效果原文：“双方基本分有8000以上的相差的场合才能发动。双方基本分变成3000。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c17178486.condition)
	e1:SetOperation(c17178486.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数：判定发动时双方基本分是否满足效果原文中“有8000以上的相差”这一前提。
function c17178486.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判定条件：自己LP减去对方LP的差值不低于8000，或者对方LP减去自己LP的差值不低于8000，两者任一成立即可发动。
	return Duel.GetLP(tp)-Duel.GetLP(1-tp)>=8000 or Duel.GetLP(1-tp)-Duel.GetLP(tp)>=8000
end
-- 定义效果处理函数：效果发动后执行“双方基本分变成3000”的后续操作。
function c17178486.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 将自己当前的基本分设置为3000。
	Duel.SetLP(tp,3000)
	-- 将对方当前的基本分设置为3000。
	Duel.SetLP(1-tp,3000)
end
