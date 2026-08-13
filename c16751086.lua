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
-- 该函数是效果发动时的处理：由于是必发的诱发效果，且无发动条件限制，chk==0时直接返回true表示可发动；随后登记本次操作效果为将对方卡组上方3张卡送去墓地。
function c16751086.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的处理信息：类别为卡组送墓（CATEGORY_DECKDES），对象不取对象，预计将对方（1-tp）卡组最上方3张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,3)
end
-- 该函数是效果处理时的操作：实际执行将对方卡组最上方3张卡送去墓地。
function c16751086.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因（REASON_EFFECT）将对方（1-tp）卡组最上方3张卡送去墓地。
	Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
end
