--ロスタイム
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方基本分是4000以上的场合，自己基本分变成比对方少1000的数值。
function c72453068.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方基本分是4000以上的场合，自己基本分变成比对方少1000的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,72453068+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c72453068.condition)
	e1:SetOperation(c72453068.activate)
	c:RegisterEffect(e1)
end
-- 定义卡片发动的条件函数
function c72453068.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方基本分是否在4000以上，且自己当前基本分不等于对方基本分减去1000的数值
	return Duel.GetLP(1-tp)>=4000 and Duel.GetLP(tp)~=Duel.GetLP(1-tp)-1000
end
-- 定义卡片发动时的效果处理函数
function c72453068.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，检查对方基本分是否在4000以上，且自己当前基本分不等于对方基本分减去1000的数值
	if Duel.GetLP(1-tp)>=4000 and Duel.GetLP(tp)~=Duel.GetLP(1-tp)-1000 then
		-- 将自己的基本分变更为对方基本分减去1000的数值
		Duel.SetLP(tp,Duel.GetLP(1-tp)-1000)
	end
end
