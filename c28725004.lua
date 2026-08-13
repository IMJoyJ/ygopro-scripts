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
-- 触发条件判定：效果对象（此卡）在表示形式变更前是攻击表示，且变更后为守备表示时才满足发动条件。
function c28725004.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_ATTACK) and e:GetHandler():IsPosition(POS_DEFENSE)
end
-- 效果处理：当条件满足时，执行洗切自己卡组的操作。
function c28725004.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 洗切玩家tp的卡组，即发动者自己的卡组。
	Duel.ShuffleDeck(tp)
end
