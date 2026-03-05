--ウォーム・ワーム
-- 效果：
-- ①：这张卡被破坏的场合发动。从对方卡组上面把3张卡送去墓地。
function c16751086.initial_effect(c)
	-- ①：这张卡被破坏的场合发动。从对方卡组上面把3张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16751086,0))  --"卡组送墓"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetTarget(c16751086.target)
	e1:SetOperation(c16751086.operation)
	c:RegisterEffect(e1)
end
-- 效果处理时设置操作信息，确定将对方卡组最上面3张卡送去墓地
function c16751086.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，指定对方卡组最上面3张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,3)
end
-- 效果发动时执行的操作函数，用于处理将对方卡组最上面3张卡送去墓地
function c16751086.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 执行将对方卡组最上面3张卡以效果为原因送去墓地
	Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
end
