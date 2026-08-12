--悪魔の知恵
-- 效果：
-- 这张卡的表示形式从攻击表示变成守备表示时，洗自己的卡组。
function c28725004.initial_effect(c)
	-- 这张卡的表示形式从攻击表示变成守备表示时，洗自己的卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28725004,0))  --"洗卡组"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetCondition(c28725004.condition)
	e1:SetOperation(c28725004.operation)
	c:RegisterEffect(e1)
end
-- 判断该卡在位置变化前是否为攻击表示且当前位置是否为守备表示
function c28725004.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_ATTACK) and e:GetHandler():IsPosition(POS_DEFENSE)
end
-- 将控制者卡组进行洗切
function c28725004.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 洗切当前玩家的卡组
	Duel.ShuffleDeck(tp)
end
