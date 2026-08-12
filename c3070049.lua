--スノー・ドラゴン
-- 效果：
-- 这张卡被战斗或者卡的效果破坏送去墓地时，给场上表侧表示存在的全部怪兽放置1个冰指示物。
function c3070049.initial_effect(c)
	-- 这张卡被战斗或者卡的效果破坏送去墓地时，给场上表侧表示存在的全部怪兽放置1个冰指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3070049,0))  --"放置指示物"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c3070049.condition)
	e1:SetOperation(c3070049.operation)
	c:RegisterEffect(e1)
end
c3070049.mentioned_counter={
	[0x1015]=true,
}
-- 发动条件：这张卡被战斗或者卡的效果破坏送去墓地时（检查自身是否因破坏而送去墓地）。
function c3070049.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 效果处理：给双方场上表侧表示存在的全部怪兽逐个放置1个冰指示物。
function c3070049.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检索双方场上所有可以放置冰指示物的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x1015,1)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1015,1,REASON_EFFECT)
		tc=g:GetNext()
	end
end
