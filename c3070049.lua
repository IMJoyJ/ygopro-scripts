--スノー・ドラゴン
-- 效果：
-- 这张卡被战斗或者卡的效果破坏送去墓地时，给场上表侧表示存在的全部怪兽放置1个冰指示物。
function c3070049.initial_effect(c)
	-- 诱发必发效果，对应一速的【……发动】
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3070049,0))  --"放置指示物"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c3070049.condition)
	e1:SetOperation(c3070049.operation)
	c:RegisterEffect(e1)
end
-- 检查此卡是否因破坏而送去墓地
function c3070049.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 检索场上所有可以放置冰指示物的怪兽并放置1个冰指示物
function c3070049.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的场上怪兽组
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x1015,1)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1015,1,REASON_EFFECT)
		tc=g:GetNext()
	end
end
